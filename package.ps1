chcp 65001

$start = Get-Date

$basePath = ".\build\app\outputs"
$allApksPath = $basePath + "\all_apks"
$releasePath = $basePath + "\apk\release"

if (Test-Path $allApksPath) {
    Remove-Item $allApksPath -Recurse -Force
} 
mkdir $allApksPath

flutter clean

function New-Apk {
    param (
        [Parameter()]
        [string]$channel,
        [Parameter()]
        [string]$environment,
        [Parameter()]
        [string]$platforms,
        [Parameter()]
        [string]$qnhd,
        [Parameter()]
        [string]$qnhdpic
    )
    $channelPath = $allApksPath + "\" + $channel + "_" + $environment
    New-Item $channelPath -ItemType "directory"
    $arguments = @(
        "--dart-define=CHANNEL=$channel",
        "--dart-define=ENVIRONMENT=$environment",
        "--dart-define=QNHD=$qnhd",
        " --dart-define=QNHDPIC=$qnhdpic"
    ) -join " "
    flutter build apk  $arguments  --target-platform $platforms --split-per-abi
    Move-Item  -Path ($releasePath + "\*") -Destination $channelPath
}

# RELEASE版
# 每个渠道下有32位和64位两个apk

$qnhd = ""
$qnhdpic = ""
$channels = @("HUAWEI", "XIAOMI", "OPPO", "VIVO", "DOWNLOAD")
foreach ($channel in $channels) {
    New-Apk -channel $channel -environment "RELEASE" -platforms "android-arm,android-arm64" -qnhd $qnhd -qnhdpic $qnhdpic
} 

# DEBUG版
# 仅打包64位

$qnhd = ""
$qnhdpic = ""
New-Apk -channel "OTHER" -environment "DEBUG" -platforms "android-arm64" -qnhd $qnhd -qnhdpic $qnhdpic

tree $allApksPath /F

$end = Get-Date

Write-Host -ForegroundColor Red ('Total Runtime: ' + ($end - $start).TotalSeconds)