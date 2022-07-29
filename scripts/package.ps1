param(
    [Parameter(mandatory=$true)]
    [string]$version,
    [Parameter(mandatory=$true)]
    [int]$versionCode
)

$allApksPath = "..\..\all_apks"

if (Test-Path $allApksPath) {
    Remove-Item $allApksPath -Recurse -Force
} 
mkdir $allApksPath

function New-Apk {
    param (
        [Parameter()]
        [string]$environment,
        [Parameter()]
        [string]$platforms
    )

    $arguments = @{
        environment = $environment
        platforms   = $platforms
        version     = $version
        versionCode = $versionCode
    }
    .\new-apk.ps1 @arguments
}

# RELEASE版 - 正式服务器 + com.twt.service 无注释
# 打包32和64位
New-Apk -environment "RELEASE" -platforms "android-arm,android-arm64"

# ONLINE_TEST版 - 正式服务器 + com.twt.service + 注释
# 仅打包64位
New-Apk -environment "ONLINE_TEST" -platforms "android-arm64"

# DEVELOP版 - 测试服务器 + com.twt.service.develop + 注释
# 仅打包64位
New-Apk -environment "DEVELOP" -platforms "android-arm64"

tree $allApksPath /F