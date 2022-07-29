param(
    [Parameter(mandatory=$true)]
    [string]$version,
    [Parameter(mandatory=$true)]
    [int]$versionCode,
    [Parameter()]
    [bool]$rebuild = $false
)

$allApksPath = "..\..\all_apks"

if (!(Test-Path $allApksPath)) {
    mkdir $allApksPath   
}

function Get-FixZip {
    param (
        [Parameter()]
        [String] $location
    )
    Set-Location ($allApksPath + "\" + $location)
    Get-ChildItem .\*.apk | ForEach-Object {
        $name = (Get-Item $_ ).Basename
        $fix_path = ".\${name}_fix.zip"
        if (!(Test-Path $fix_path)) {
            if (!(Test-Path .\$name.so) -and !(Test-Path .\libapp.so) -and !(Test-Path .\$name) -and !(Test-Path .\$name.zip)) {
                Copy-Item $_ -Destination .\$name.zip
            }
            if (!(Test-Path .\$name.so) -and !(Test-Path .\libapp.so) -and !(Test-Path .\$name)) {
                Expand-Archive .\$name.zip -DestinationPath .\$name
            }
            if (!(Test-Path .\$name.so) -and !(Test-Path .\libapp.so)) {
                Move-Item .\$name\lib\arm64-v8a\libapp.so -Destination .\libapp.so
            }
            if (!(Test-Path .\$name.so)) {
                Rename-Item .\libapp.so -NewName .\$name.so
            }
            Compress-Archive .\$name.so -DestinationPath $fix_path
            if (Test-Path .\$name.zip ) { Remove-Item .\$name.zip }
            if (Test-Path .\$name.so ) { Remove-Item .\$name.so }
            if (Test-Path .\$name ) { Remove-Item .\$name -Recurse }
        }
        $zipFile = Get-Item $fix_path
        Write-Host "-------------------- fix --------------------"
        Write-Host ("{0} {1:N2}Mb" -f $zipFile.FullName , ($zipFile.Length / 1mb))
        Write-Host "-------------------- fix --------------------"
    }
    Set-Location ..\..\WePeiYang-Flutter\scripts\
}

$environment = "ONLINE_TEST_${version}"

$environmentPath = $allApksPath + "\" + $environment

$arguments = @{
    environment = $environment 
    platforms   = "android-arm64"
    version     = $version
    versionCode = $versionCode
}

if ($rebuild -or !(Test-Path $environmentPath)) {
    .\new-apk.ps1 @arguments
}

Get-FixZip $environment

Invoke-Item $allApksPath