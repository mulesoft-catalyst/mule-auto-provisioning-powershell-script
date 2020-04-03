 function InstallMuleLicenseFile(
  [Parameter(Mandatory=$true)][string]$MuleHome,
  [Parameter(Mandatory=$true)][string]$MuleLicenseUrl,
  [string]$AwsBucketName) {
  Write-Host ""
  Write-Host "===================="
  Write-Host "Install Mule License"
  Write-Host "===================="

  $MuleBinPath = "$($MuleHome)\bin"
  
  $MuleLicensePath = DownloadFile "$MuleLicenseUrl" "$MuleBinPath" "$AwsBucketName";
  
  Write-Host "`r`n[SETUP] Mule License Downloaded to: $MuleLicensePath. Install License"

  cd "$MuleBinPath"
  $MuleLicenseFileName = [System.IO.Path]::GetFileName($MuleLicensePath)
  ./mule -installLicense "$MuleLicenseFileName"

  Write-Host "`r`n[SETUP] License installed" | Write-Host;
} 
