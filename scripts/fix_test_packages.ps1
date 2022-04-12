param(
    [Parameter(mandatory = $true)]
    [string]$version,
    [Parameter(mandatory = $true)]
    [int]$versionCode
)

$v = $version -split '[.]+'

for ($i = 0; $i -lt 3; $i++) {
    .\hotfix_package.ps1 -version $version -versionCode $versionCode -rebuild $true
    $version = "$($v[0]).$($v[1]).$([int]$v[2] + 1)"
    $versionCode = $versionCode + 1
}