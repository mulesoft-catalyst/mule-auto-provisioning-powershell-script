 function DownloadMule(
  [Parameter(Mandatory=$true)][string]$MuleBinaryUrl,
  [Parameter(Mandatory=$true)][string]$TempFileDirectory,
  [Parameter(Mandatory=$true)][string]$MuleInstallDir,
  [string]$AwsBucketName) {
  
  Write-Host ""
  Write-Host "====================="
  Write-Host "Download Mule Runtime"
  Write-Host "====================="

  $MuleBinaryPath = DownloadFile "$MuleBinaryUrl" "$TempFileDirectory" "$AwsBucketName"

  Write-Host "`r`n[SETUP] Mule Runtime Downloaded to: $MuleBinaryPath. Unpack file in directory: $MuleInstallDir"

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($MuleBinaryPath, $MuleInstallDir)

  $MuleHome = Get-ChildItem -Path $MuleInstallDir | Select -Expand FullName -First 1
  
  Write-Host "`r`n[SETUP] Mule Runtime unpacked. Mule home: $MuleHome. Listed files:"
  
  ls "$MuleHome" | Write-Host;

  return $MuleHome
}

function UpdateWrapperConf([Parameter(Mandatory=$true)][string]$MuleHome,
  [ValidateRange(0,32768)][int]$MuleConfInitMemory = 1024,
  [ValidateRange(0,32768)][int]$MuleConfMaxMemory = 1024,
  [ValidateRange(0,32768)][int]$MuleConfMaxMetaspace = 256,
  [ValidateSet('strict','flexible','disabled')][string]$MuleConfGateKeeper = "flexible",
  [string]$MuleConfAnypointClientId,
  [string]$MuleConfAnypointClientSecret,
  [string]$MuleConfEnv,
  [string]$MuleConfKey,
  [string]$NTServiceName) {

  Write-Host ""
  Write-Host "============================"
  Write-Host "Update Wrapper Configuration"
  Write-Host "============================"

  $WrapperConfDir="$($MuleHome)\conf\wrapper.conf"

  Write-Host "`r`n[SETUP] Add include to Wrapper conf file: $WrapperConfDir"

  "#include %MULE_BASE%/conf/wrapper-custom.conf" | Add-Content "$WrapperConfDir"

  $WrapperCustomConfDir="$($MuleHome)\conf\wrapper-custom.conf"

  Write-Host "`r`n[SETUP] Set Properties in custom Wrapper conf file: $WrapperCustomConfDir"

  "wrapper.java.initmemory=$MuleConfInitMemory" | Set-Content "$WrapperCustomConfDir"
  "wrapper.java.maxmemory=$MuleConfMaxMemory" | Add-Content "$WrapperCustomConfDir"
  "wrapper.java.additional.90=-XX:MaxMetaspaceSize=$($MuleConfMaxMetaspace)m" | Add-Content "$WrapperCustomConfDir"
  "wrapper.java.additional.91=-Danypoint.platform.gatekeeper=$MuleConfGateKeeper" | Add-Content "$WrapperCustomConfDir"

  if($MuleConfAnypointClientId) { "wrapper.java.additional.92=-Danypoint.platform.client_id=$MuleConfAnypointClientId" | Add-Content "$WrapperCustomConfDir" };
  if($MuleConfAnypointClientSecret) { "wrapper.java.additional.93=-Danypoint.platform.client_secret=$MuleConfAnypointClientSecret" | Add-Content "$WrapperCustomConfDir" };
  if($MuleConfEnv) { "wrapper.java.additional.94=-Dmule.env=$MuleConfEnv" | Add-Content "$WrapperCustomConfDir" };
  if($MuleConfKey) { "wrapper.java.additional.95=-Dmule.key=$MuleConfKey" | Add-Content "$WrapperCustomConfDir" };
  if($NTServiceName) {
    "wrapper.ntservice.name=$NTServiceName" | Add-Content "$WrapperCustomConfDir";
    "wrapper.ntservice.displayname=$NTServiceName" | Add-Content "$WrapperCustomConfDir";
  };

  Write-Host "`r`n[SETUP] Properties Set. Verify file: $WrapperCustomConfDir";
  Get-Content $WrapperCustomConfDir | Write-Host;

}

function InstallMuleService([Parameter(Mandatory=$true)][string]$MuleHome) {
  Write-Host ""
  Write-Host "==================="
  Write-Host "Install Mule Server"
  Write-Host "==================="
  cd "$MuleHome"
  bin\mule.bat install | Write-Host;

  Write-Host "`r`n[SETUP] Mule Server installed as a Windows Service"
}

function StartMuleService([Parameter(Mandatory=$true)][string]$MuleHome) {
  Write-Host ""
  Write-Host "================="
  Write-Host "Start Mule Server"
  Write-Host "================="
  cd "$MuleHome"
  bin\mule.bat start | Write-Host;

  Write-Host "`r`n[SETUP] Mule service started"
}


function StopMuleService([Parameter(Mandatory=$true)][string]$MuleHome) {
  Write-Host ""
  Write-Host "================"
  Write-Host "Stop Mule Server"
  Write-Host "================"
  cd "$MuleHome"
  bin\mule.bat stop | Write-Host;

  Write-Host "`r`n[SETUP] Mule service stopped"
} 
