# Original code from https://github.com/dfinke/ImportExcel/blob/master/InstallModule.ps1
param ($fullPath,[switch]$SystemInstall)
if (-not $fullPath) {
    if($SystemInstall)
      {
        $whereFilter = {$_ -notlike ([System.Environment]::GetFolderPath("UserProfile")+"*") -and $_ -notlike "$pshome*"}
      }
    else
      {
        $whereFilter = {$_ -like ([System.Environment]::GetFolderPath("UserProfile")+"*")}
      }

    $fullpath = $env:PSModulePath -split ":(?!\\)|;|," | Where-Object $whereFilter | Select-Object -First 1
    $fullPath = Join-Path $fullPath -ChildPath "DNSClientPlus"
}
Push-location $PSScriptRoot
Robocopy . $fullPath /XF InstallModule.ps1 README.md
Pop-Location