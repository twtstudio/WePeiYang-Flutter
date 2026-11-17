param(
    [Parameter(mandatory = $true)]
    [string]$version,
    [Parameter(mandatory = $true)]
    [int]$versionCode
)

$v = $version -split '[.]+'
$code = [int]$v[2]

for ($i = 0; $i -lt 3; $i++) {
    .\hotfix_package.ps1 -version $version -versionCode $versionCode -rebuild $true
    $code = $code + 1
    $version = "$($v[0]).$($v[1]).$code"
    $versionCode = $versionCode + 1
}