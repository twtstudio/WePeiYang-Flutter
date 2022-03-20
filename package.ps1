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

# RELEASE版
# 每个渠道下有32位和64位两个apk

$type = "RELEASE"
$qnhd = ""
$qnhdpic = ""
$channels = @("HUAWEI", "XIAOMI", "OPPO", "VIVO", "DOWNLOAD")
$platforms = "android-arm,android-arm64"
foreach ($channel in $channels) {
    $channelPath = $allApksPath + "\" + $channel + "_" + $type
    New-Item $channelPath -ItemType "directory"
    flutter build apk --dart-define=FLAVOR=$channel --dart-define=VERSION=$type --dart-define=QNHD=$qnhd --dart-define=QNHDPIC=$qnhdpic --target-platform $platforms --split-per-abi
    Move-Item  -Path ($releasePath + "\*") -Destination $channelPath
} 

# DEBUG版
# 仅打包64位

$type = "DEBUG"
$qnhd = ""
$qnhdpic = ""
$channel = "OTHER"
$platform = "android-arm64"
$channelPath = $allApksPath + "\" + $channel + "_" + $type
New-Item $channelPath -ItemType "directory"
flutter build apk --dart-define=FLAVOR=$channel --dart-define=VERSION=$type --dart-define=QNHD=$qnhd --dart-define=QNHDPIC=$qnhdpic --target-platform $platform --split-per-abi
Move-Item  -Path ($releasePath + "\*") -Destination $channelPath

tree $allApksPath /F

$end = Get-Date

Write-Host -ForegroundColor Red ('Total Runtime: ' + ($end - $start).TotalSeconds)