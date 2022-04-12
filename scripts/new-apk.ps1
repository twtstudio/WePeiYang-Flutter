param (
    [Parameter(mandatory = $true)]
    [string]$environment,
    [Parameter(mandatory = $true)]
    [string]$platforms,
    [Parameter()]
    [string]$version,
    [Parameter()]
    [int]$versionCode
)

$releasePath = "..\build\app\outputs\apk\release"
$allApksPath = "..\..\all_apks"

$environmentPath = $allApksPath + "\" + $environment

if (Test-Path $environmentPath) {
    Remove-Item $environmentPath -Recurse -Force
} 

New-Item $environmentPath -ItemType "directory"

$yaml_file = '..\pubspec.yaml'
$config_file = '..\lib\commons\environment\config.dart'

$version_array = (((Get-Content -Path $yaml_file) -match '(?<=version:\s+)[0-9.+]+') -split '\s')[1] -split '\+'

if ($version -eq '') {
    $version = $version_array[0]
}
(Get-Content -Path $config_file) -replace "VERSION\s*=\s*`"[0-9.]+`"", "VERSION = `"$version`"" | Set-Content $config_file -Encoding UTF8

if ($versionCode -eq 0) {
    $versionCode = $version_array[1]
} 
(Get-Content -Path $config_file) -replace 'VERSIONCODE\s*=\s*[0-9]+', "VERSIONCODE = $versionCode" | Set-Content $config_file -Encoding UTF8

(Get-Content -Path $yaml_file) -replace '(?<=version:\s+)[0-9.+]+', "$version+$versionCode" | Set-Content $yaml_file -Encoding UTF8

$arguments = @(
    "--dart-define=ENVIRONMENT=$environment",
    "--dart-define=VERSION=$version",
    "--dart-define=VERSIONCODE=$versionCode"
)
flutter build apk  @arguments  --target-platform $platforms --split-per-abi
Move-Item  -Path ($releasePath + "\*") -Destination $environmentPath