 function InstallJava(
  [Parameter(Mandatory=$true)][string]$JavaBinaryUrl,
  [Parameter(Mandatory=$true)][string]$TempFileDirectory,
  [Parameter(Mandatory=$true)][string]$JavaInstallDir,
  [Parameter(Mandatory=$true)][string]$JavaImplementation,
  [string]$AwsBucketName) {
  
  Write-Host ""
  Write-Host "============"
  Write-Host "Install Java"
  Write-Host "============"

  $JavaBinaryPath = DownloadFile -FileUrl "$JavaBinaryUrl" -FileDirectory "$TempFileDirectory" -AwsBucketName "$AwsBucketName"

  Write-Host "`r`n[SETUP] Java Downloaded to $JavaBinaryPath"
  cd $TempFileDirectory

  if($JavaImplementation -eq "openjdk") {
    Write-Host "`r`n[SETUP] Uncompress OpenJDK file $JavaBinaryPath in $JavaInstallDir"

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($JavaBinaryPath, $JavaInstallDir)
    $JavaHome = Get-ChildItem -Path $JavaInstallDir | Select -Expand FullName -First 1

    Write-Host "`r`n[SETUP] Java home located in $JavaHome"

    $OldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
    $NewPath = "$OldPath;$JavaHome\bin"
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $NewPath
    $env:Path = $NewPath

  } elseif ($JavaImplementation -eq "oraclejdk") {
    Write-Host "`r`n[SETUP] Execute silent install in directory: $JavaInstallDir"
    "INSTALL_SILENT=Enable" | Set-Content "$TempFileDirectory/JavaInstallConfig.txt"
    "INSTALLDIR=$JavaInstallDir" | Add-Content "$TempFileDirectory/JavaInstallConfig.txt"
    "AUTO_UPDATE=Enable" | Add-Content "$TempFileDirectory/JavaInstallConfig.txt"
    "WEB_JAVA_SECURITY_LEVEL=VH" | Add-Content "$TempFileDirectory/JavaInstallConfig.txt"

    start-process $JavaBinaryPath INSTALLCFG=$TempFileDirectory/JavaInstallConfig.txt -Wait

    Write-Host "`r`n[SETUP] Java Installed"

    $OldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path

    $NewPath = "$OldPath;$JavaInstallDir\bin"

    Write-Host "`r`n[SETUP] Path will be set to: $NewPath"

    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $NewPath

    $env:Path = $NewPath
  } else {
    Write-Host "`r`n[SETUP] Java implementation option not valid";
  }

  Write-Host "`r`n[SETUP] Path updated"

}

function  VerifyJava {
  Write-Host ""
  Write-Host "==================="
  Write-Host "Verify Java Version"
  Write-Host "==================="

  Write-Host "`r`n[SETUP] Running Java Version command"

  java -version | Write-Host;

  return $?;

} 
