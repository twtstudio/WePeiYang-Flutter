#!/usr/bin/env bash
#
# 反解 release(AOT + --obfuscate) 崩溃栈
#
# release 包的栈帧只剩裸地址(形如 _kDartIsolateSnapshotInstructions+0x...),
# 需要用打包时 --split-debug-info 产出的符号表反解成 文件:行号。
#
# 用法:
#   scripts/symbolize.sh talker_log.txt             # 从文件读(整份日志直接喂)
#   pbpaste | scripts/symbolize.sh                  # 从管道/剪贴板读
#   scripts/symbolize.sh crash.txt -d build/symbols/6.x.x_abc1234
#
# 选项:
#   -d, --symbols-dir DIR   符号表所在目录(含 app.android-arm64.symbols 等)
#                           默认依次尝试: HLQ_Struggle, build/symbols/*
#   -h, --help              显示帮助
#
# 说明:
#   * 一份日志里有多个崩溃会全部找出来逐个反解, 无关的 [http-...] 等日志自动忽略。
#   * 架构(arm/arm64)从每个栈的 `arch:` 行自动识别, 各自选对应的 .symbols。
#   * build_id 必须和产出该包的构建一致, 否则反解结果是错的; 校验由 flutter
#     symbolize 负责, 对不上会报错。线上崩溃去对应 CI run 下载
#     `symbols-<版本号_短SHA>` artifact, 用 -d 指定。

set -euo pipefail

SYMBOLS_DIR=""
TRACE_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--symbols-dir) SYMBOLS_DIR="$2"; shift 2 ;;
    -h|--help) sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "未知选项: $1" >&2; exit 2 ;;
    *) TRACE_FILE="$1"; shift ;;
  esac
done

# 项目根目录(脚本在 scripts/ 下)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# --- 读取崩溃栈(文件优先, 否则 stdin) ---
TRACE_RAW="$(if [[ -n "$TRACE_FILE" ]]; then cat "$TRACE_FILE"; else cat; fi)"
if [[ -z "${TRACE_RAW// /}" ]]; then
  echo "错误: 没有读到栈内容。传文件或用管道喂进来。" >&2
  exit 2
fi

# --- 拆出所有 VM dump 本体(一份日志里可能有多个崩溃) ---
#   - 头部那行可能带 talker 前缀(如 "StackTrace: *** ***"), 去掉。
#   - 每个 dump 从 `*** ***` 开始; 出现栈帧后, 遇到既不是帧/异步挂起/空行的内容
#     (如后续 [http-...] 日志)即视为该 dump 结束, 避免把无关日志混进去。
#   - 每个 dump 写成 blkNNN.txt, 逐个反解。
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

printf '%s\n' "$TRACE_RAW" | awk -v dir="$TMP" '
  /\*\*\* \*\*\*/ {
    n++; f=1; seen=0
    out=sprintf("%s/blk%03d.txt", dir, n)
    sub(/^.*\*\*\* \*\*\*/, "*** ***")
    print > out
    next
  }
  f {
    if (seen && $0 !~ /^[[:space:]]*#/ && $0 !~ /asynchronous suspension/ && $0 !~ /^[[:space:]]*$/) {
      f=0; next
    }
    if ($0 ~ /^[[:space:]]*#[0-9]/) seen=1
    print > out
  }
'

shopt -s nullglob
BLOCKS=("$TMP"/blk*.txt)
if [[ ${#BLOCKS[@]} -eq 0 ]]; then
  echo "错误: 找不到 '*** *** ***' 开头的 VM dump。请确认是原始混淆栈(含 build_id 等头部)。" >&2
  exit 2
fi

echo "发现 ${#BLOCKS[@]} 个崩溃栈" >&2
echo >&2

# 反解单个 dump 文件
symbolize_one() {
  local block="$1" idx="$2" total="$3"
  local arch sym_name sym_file bid

  arch="$(grep -oE 'arch: ?[a-z0-9]+' "$block" | head -1 | sed 's/arch: *//')"
  case "$arch" in
    arm64) sym_name="app.android-arm64.symbols" ;;
    arm)   sym_name="app.android-arm.symbols" ;;
    x64)   sym_name="app.android-x64.symbols" ;;
    "")    echo "  [$idx/$total] ✗ 栈里没有 'arch:' 行, 跳过。" >&2; return 1 ;;
    *)     echo "  [$idx/$total] ✗ 不支持的架构 '$arch', 跳过。" >&2; return 1 ;;
  esac

  # 符号表目录: 命令行指定 > HLQ_Struggle > build/symbols 最新
  local dir="$SYMBOLS_DIR"
  if [[ -z "$dir" ]]; then
    if [[ -f "HLQ_Struggle/$sym_name" ]]; then
      dir="HLQ_Struggle"
    else
      dir="$(ls -dt build/symbols/*/ 2>/dev/null | head -1 || true)"
    fi
  fi
  sym_file="${dir%/}/$sym_name"
  if [[ ! -f "$sym_file" ]]; then
    echo "  [$idx/$total] ✗ 找不到符号表 '$sym_file' (arch=$arch)。用 -d 指定或去 CI 下载。" >&2
    return 1
  fi

  # 栈里的 build_id 是 Dart snapshot 哈希(非 ELF GNU build-id, 不可直接比),
  # 真正校验交给 flutter symbolize; 这里只打印供和 CI 归档对照。
  bid="$(sed -nE "s/.*build_id: ?'([0-9a-fA-F]+)'.*/\1/p" "$block" | head -1)"

  echo "━━━━━━━━━━ 崩溃 $idx/$total ━━━━━━━━━━"
  echo "→ 架构: $arch   build_id: ${bid:-未知}   符号表: $sym_file"
  echo
  if ! flutter symbolize -d "$sym_file" -i "$block"; then
    echo "✗ 反解失败(崩溃 $idx)。多半是 build_id 对不上 —— 符号表不是产出该包的构建。" >&2
    return 1
  fi
  echo
}

rc=0
i=0
for block in "${BLOCKS[@]}"; do
  i=$((i + 1))
  symbolize_one "$block" "$i" "${#BLOCKS[@]}" || rc=1
done
exit "$rc"
