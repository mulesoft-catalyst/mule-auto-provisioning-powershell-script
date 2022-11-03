 param (
  [switch]$Help = $false,
  [switch]$InstallMuleRuntime = $false,
  [switch]$ConfigureMuleRuntime = $false,
  [switch]$StartMuleService = $false,
  [switch]$StopMuleService = $false,
  [string]$TempFileDirectory = "$($env:USERPROFILE)",

  [switch]$IgnoreJavaInstall = $false,
  [switch]$IgnoreMuleInstall = $false,
  [switch]$IgnoreMuleWrapperConfUpdate = $false,
  [switch]$IgnoreMuleRegistration = $false,
  [switch]$IgnoreMuleLicenseInstall = $false,

  [string]$JavaBinaryUrl,
  [string]$AwsBucketName,
  [string]$JavaInstallDir = "C:\java",
  [ValidateSet('openjdk','oraclejdk')][string]$JavaImplementation = "oraclejdk",
  [string]$MuleBinaryUrl,
  [string]$MuleInstallDir = "C:\mule",
  [string]$MuleHome,

  [ValidateRange(0,32768)][int]$MuleConfInitMemory = 1024,
  [ValidateRange(0,32768)][int]$MuleConfMaxMemory = 1024,
  [ValidateRange(0,32768)][int]$MuleConfMaxMetaspace = 256,
  [ValidateSet('strict','flexible','disabled')][string]$MuleConfGateKeeper = "flexible",
  [string]$MuleConfAnypointClientId,
  [string]$MuleConfAnypointClientSecret,
  [string]$MuleConfEnv,
  [string]$MuleConfKey,
  [string]$NTServiceName,
  [string]$RegisterToken,
  [string]$ServerName,
  [string]$MuleLicenseUrl
)

$ErrorActionPreference = "Stop";

. ".\Download-File.ps1";
. ".\Install-Java.ps1";
. ".\Install-Mule.ps1";
. ".\Install-Mule-License.ps1";
. ".\Register-Mule-Server.ps1";

function InstallMuleRuntime() {
  Write-Host "===================="
  Write-Host "Install Mule Runtime"
  Write-Host "===================="

  Write-Host "`r`n[SETUP] Directory for temporary files: $TempFileDirectory"

  if($IgnoreJavaInstall) {
    Write-Host "`r`n[SETUP] Java install skipped";
  } else {
    InstallJava -JavaBinaryUrl "$JavaBinaryUrl" -TempFileDirectory "$TempFileDirectory" -JavaInstallDir "$JavaInstallDir" -JavaImplementation "$JavaImplementation" -AwsBucketName "$AwsBucketName";
  }

  $JavaVersionInstalled = VerifyJava;

  if(!$JavaVersionInstalled) {
    Write-Host "`r`n[SETUP] Required Java version not installed";
  } else {
    Write-Host "`r`n[SETUP] Continue with Install";

    if($IgnoreMuleInstall) {
      Write-Host "`r`n[SETUP] Mule install skipped";
    } else {
      $MuleHome = DownloadMule -MuleBinaryUrl "$MuleBinaryUrl" -TempFileDirectory "$TempFileDirectory" -MuleInstallDir "$MuleInstallDir" -AwsBucketName "$AwsBucketName";
      Write-Host "`r`n[SETUP] Mule Home: $MuleHome";
      InstallMuleService -MuleHome "$MuleHome" ;
    }
  };
  
}

function ConfigureMuleRuntime(
  [Parameter(Mandatory=$true)][string]$MuleHome) {
  Write-Host "======================"
  Write-Host "Configure Mule Runtime"
  Write-Host "======================"

  Write-Host "`r`n[SETUP] Mule Home: $MuleHome"

  Write-Host "`r`n[SETUP] Stop Mule Service if it's running";
  StopMuleService -MuleHome $MuleHome;

  if($IgnoreMuleWrapperConfUpdate) {
    Write-Host "`r`n[SETUP] Wrapper Conf update skipped";
  } else {
    UpdateWrapperConf -MuleHome $MuleHome -MuleConfInitMemory $MuleConfInitMemory -MuleConfMaxMemory $MuleConfMaxMemory -MuleConfMaxMetaspace $MuleConfMaxMetaspace -MuleConfGateKeeper $MuleConfGateKeeper -MuleConfAnypointClientId $MuleConfAnypointClientId -MuleConfAnypointClientSecret $MuleConfAnypointClientSecret -MuleConfEnv $MuleConfEnv -MuleConfKey $MuleConfKey -NTServiceName $NTServiceName;
  }

  if($IgnoreMuleRegistration) {
    Write-Host "`r`n[SETUP] Server registration skipped";
  } else {
    RegisterMuleServer -MuleHome $MuleHome -RegisterToken $RegisterToken -ServerName $ServerName;
  };

  if($IgnoreMuleLicenseInstall) {
    Write-Host "`r`n[SETUP] Mule License install skipped";
  } else {
    InstallMuleLicenseFile -MuleHome $MuleHome -MuleLicenseUrl $MuleLicenseUrl -AwsBucketName $AwsBucketName;
  };

  Write-Host "`r`n[SETUP] Start Mule Service";
  StartMuleService -MuleHome $MuleHome;
}

function Help {
  Write-Host "
Mule 4 Auto Provisioning script (v1.10)
=======================================

Global Arguments:
  Arguments required in the install and configure Mule Runtime operations

  -TempFileDirectory: Directory where the files will be downloaded (Default: User home)
  -AwsBucketName: The AWS Bucket name to download the files from. If not sent, AWS S3 is not used, and the URL is considered an HTTP direct download (Optional)

  Note: If the files will be downloaded from Amazon S3, the URL argument should contain the key, without the S3 Bucket, i.e.:

  -MuleBinaryUrl `"mulepoc/mule-runtime.zip`"

  The IAM Roles should be properly configured.
  The file name will be obtained from the URL, in this case it will be `"mule-runtime.zip`".

Operations:
  
  ====
  Help
  ====

    Print help menu

    i.e.: .\Mule-Runtime-Setup.ps1 -Help
  
  ====================
  Install Mule Runtime
  ====================
    Tasks:
      - Download Java binaries
      - Install Java
      - Download Mule binaries
      - Uncompress Mule
      - Create Mule Windows Service

    Arguments:
      -InstallMuleRuntime: Executes this operation
      -IgnoreJavaInstall: (Flag) Skips the Java install
      -IgnoreMuleInstall: (Flag) Skips the Mule install
      -JavaBinaryUrl: URL to download JDK 8
      -JavaInstallDir: Directory where Java will be installed (Default: C:\java)
      -JavaImplementation: Type of Java binary file (OpenJDK Zip or Oracle JDK EXE)
      -MuleBinaryUrl: URL to download Mule Runtime 4
      -MuleInstallDir: Directory where the Mule Runtime will be installed (Default: C:\mule)

      Note: The installation script only works with Oracle JDK Version 8.x.
      A specific set of arguments is sent to run this version of the JDK in Silent mode, without user interaction.

    i.e.: .\Mule-Runtime-Setup.ps1 -InstallMuleRuntime -JavaBinaryUrl `"Mule4PoC/jdk-8u231-windows-x64.exe`" -JavaInstallDir `"E:\java\`" -JavaImplementation `"oraclejdk`" -MuleBinaryUrl `"Mule4PoC/mule-ee-distribution-standalone-4.2.1-hf1.zip`" -MuleInstallDir `"E:\mule`"
    i.e.: .\Mule-Runtime-Setup.ps1 -InstallMuleRuntime -JavaBinaryUrl `"Mule4PoC/OpenJDK8U-jdk_x64_windows_hotspot_8u232b09.zip`" -JavaInstallDir `"E:\java\`" -JavaImplementation `"openjdk`" -MuleBinaryUrl `"Mule4PoC/mule-ee-distribution-standalone-4.2.1-hf1.zip`" -MuleInstallDir `"E:\mule`"

  
  ======================
  Configure Mule Runtime
  ======================
    Tasks:
      - Stop Mule Service
      - Update Wrapper Conf
      - Register Mule in Anypoint Runtime Manager
      - Install Mule License
      - Start Mule Service

    Arguments:
      -IgnoreMuleWrapperConfUpdate: (Flag) Skips the Wrapper Conf update
      -IgnoreMuleRegistration: (Flag) Skips the Mule registration in Anypoint Runtime Manager
      -IgnoreMuleLicenseInstall: (Flag) Skips the Mule License install
      -MuleHome: Path to Mule Runtime home directory (i.e.: `"C:\mule\mule-enterprise-standalone-4.2.1`")
      -MuleConfInitMemory: Initial memory in Mule Runtime configuration (Default: 1024)
      -MuleConfMaxMemory: Max memory in Mule Runtime configuration (Default: 1024)
      -MuleConfMaxMetaspace Max metaspace memory in Mule Runtime configuration (Default: 256)
      -MuleConfGateKeeper: Gatekeeper configuration [strict,flexible,disabled] (Default: `"flexible`")
      -MuleConfAnypointClientId: Anypoint Platform Environment Client ID for API Autodiscovery (Optional)
      -MuleConfAnypointClientSecret: Anypoint Platform Environment Client Secret for API Autodiscovery (Optional)
      -MuleConfEnv: mule.env variable to set in wrapper.conf file (Optional)
      -MuleConfKey: mule.key variable to set in wrapper.conf file (Optional)
      -NTServiceName: Mule NT Service name (Optional, default to Mule Enterprise Edition)
      -RegisterToken: Registration token provided by Anypoint Runtime Manager
      -ServerName: Name to identify the server in Anypoint Runtime Manager
      -MuleLicenseUrl: URL to download the Mule license

    i.e.: .\Mule-Runtime-Setup.ps1 -ConfigureMuleRuntime -MuleHome `"C:\mule\mule-enterprise-standalone-4.2.1`" -RegisterToken `"[REGISTER TOKEN]`" -ServerName `"test-mule`" -MuleLicenseUrl `"Mule4PoC/license.lic`"

  ==================
  Start Mule Service
  ==================

    Starts the Mule Windows Service

    Arguments:
      -MuleHome: Path to Mule Runtime home directory

    i.e.: .\Mule-Runtime-Setup.ps1 -StartMuleService -MuleHome `"C:\mule\mule-enterprise-standalone-4.2.1`"

  ==================
  Start Mule Service
  ==================

    Stops the Mule Windows Service

    Arguments:
      -MuleHome: Path to Mule Runtime home directory

    i.e.: .\Mule-Runtime-Setup.ps1 -StopMuleService -MuleHome `"C:\mule\mule-enterprise-standalone-4.2.1`"
"
}

if($Help) {
  Help;
} elseif ($InstallMuleRuntime) {
  echo "Test: $InstallJava"
  InstallMuleRuntime $InstallJava;
} elseif ($ConfigureMuleRuntime) {
  ConfigureMuleRuntime -MuleHome $MuleHome;
} elseif ($StartMuleService) {
  StartMuleService -MuleHome $MuleHome;
} elseif ($StopMuleService) {
  StopMuleService -MuleHome $MuleHome;
} else {
    Write-Host "No option selected";
} 
