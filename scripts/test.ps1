param (
    [Parameter()]
    [string]$version,
    [Parameter()]
    [int]$versionCode
)
$version
$versionCode

$yaml_file = '..\pubspec.yaml'
$config_file = '..\lib\commons\environment\config.dart'

$version_array = (((Get-Content -Path $yaml_file) -match '(?<=version:\s+)[0-9.+]+') -split '\s')[1] -split '\+'

if ($version -eq '') {
    $version = $version_array[0]
}
(Get-Content -Path $config_file) -replace "defaultValue\s*:\s*`"[0-9.]+`"", "defaultValue : `"$version`"" | Set-Content $config_file -Encoding UTF8

if ($versionCode -eq 0) {
    $versionCode = $version_array[1]
} 
(Get-Content -Path $config_file) -replace 'defaultValue\s*:\s*[0-9]+', "defaultValue : $versionCode" | Set-Content $config_file -Encoding UTF8

(Get-Content -Path $yaml_file) -replace '(?<=version:\s+)[0-9.+]+', "$version+$versionCode" | Set-Content $yaml_file -Encoding UTF8