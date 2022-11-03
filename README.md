# Mule Auto-provisioning Powershell Script

## Introduction

The purpose of these scripts is to automate the Mule Runtime install in an empty Windows Server with a Powershell script.

The script provides two commands:

**Install Mule Runtime**

Executes the steps that can be reproduced on every server equally, as downloading the Java and Mule Runtime binaries, installing Java, Mule, and creating the Mule service.

**Configure Mule Runtime**

Runs the steps that will differ for each Mule Runtime installation, as the wrapper configuration parameters and the registration against Anypoint Runtime Manager.

## Technology

- **Windows Server 2012 R2:** Tested on Windows Server 2012 R2 instances. Should work in other Windows Server versions with Powershell. Some commands may vary in newer versions of the operating system.
- **Powershell 4.0:** The script has been developed for Powershell 4.0, the default version in Windows Server 201 R2
- **JDK 8:** The script receives the instruction to install Oracle JDK or OpenJDK. In the first case, it must receive an EXE file to run a silent install, in the second one, it receives a zip file to uncompress and set its location in the PATH environment variable.
- **Mule Runtime 4.2.1:** The script has been tested with Mule 4.2.1. The commands executed and configuration defined should be compatible for any 4.2.x Mule Runtime. The parameters added to the wrapper.conf file should be reviewed for other minor versions of the Mule Runtime
- **AWS CLI:** The script provides the capability to download the required files from Amazon S3, through the AWS CLI already installed in the server. This is only intended to be used where the Windows Server instance is created in AWS EC2.

## Process

The auto-provisioning script will execute the following tasks.

### Help
Prints options and available commands

### Install Mule Runtime
- Download Java Binaries
- Install Java
  - If OpenJDK
    - Uncompress zip in installation directory
    - Set PATH environment variable.
  - If OracleJDK
    - Execute silent install
- Verify Java (Execute Java version command)
- Download Mule Binaries
- Uncompress Mule
- Create Mule Windows Service

### Configure Mule Runtime
- Stop the Mule Service
- Update Wrapper Conf
- Register Mule in Anypoint Runtime Manager
- Install Mule License
- Start Mule Service

### Start Mule Service
Start the Mule Windows Service

###Stop Mule Service
Stop the Mule Windows Service

## Configuration

The script required a set of parameters to complete all the tasks


| Parameter                   | Required | Depends On           | Type                                | Default     | Description
|:----------------------------|:---------|:---------------------|:------------------------------------|:------------|:-----------
| Help                        | No       | -                    | Flag                                | False       | Shows the information about the script
| InstallMuleRuntime          | No       | -                    | Flag                                | False       | Installs Java and the Mule Runtime
| ConfigureMuleRuntime        | No       | -                    | Flag                                | False       | Configures the Mule Runtime and Registers it against ARM
| StartMuleRuntime            | No       | -                    | Flag                                | False       | Starts the Mule Windows Service
| StopMuleRuntime             | No       | -                    | Flag                                | False       | Stops the Mule Windows Service
| TempFileDirectory           | No       | InstallMuleRuntime   | String                              | <User home> | Directory where the files will be downloaded
| IgnoreJavaInstall           | No       | InstallMuleRuntime   | Flag                                | False       | Skips the Java install step
| IgnoreMuleInstall           | No       | InstallMuleRuntime   | Flag                                | False       | Skips the Mule install step
| JavaInstallDir              | Yes      | InstallMuleRuntime   | String                              | C:\java\    | Directory where Java will be installed
| JavaImplementation          | No       | InstallMuleRuntime   | Switch (oraclejdk, openjdk)         | oraclejdk   | Defines if the Java binary is the Oracle EXE installer or the OpenJDK Zip file
| MuleBinaryUrl               | Yes      | -                    | String                              | -           | URL to download Mule Runtime 4
| MuleInstallDir              | No       | -                    | String                              | C:\mule\    | Directory where the Mule Runtime will be installed
| IgnoreMuleWrapperConfUpdate | No       | ConfigureMuleRuntime | Flag                                | False       | Skips the Wrapper conf step
| IgnoreMuleRegistration      | No       | ConfigureMuleRuntime | Flag                                | False       | Skips the Mule registration step
| IgnoreMuleLicenseInstall    | No       | ConfigureMuleRuntime | Flag                                | False       | Skips the Mule License install step
| MuleConfInitMemory          | No       | -                    | Integer                             | 1024        | Initial memory in MB
| MuleConfMaxMemory           | No       | -                    | Integer                             | 1024        | Max memory in MB
| MuleConfMaxMetaspace        | No       | -                    | Integer                             | 256         | Max metaspace memory in MB taken by the JVM
| MuleConfGateKeeper          | No       | -                    | Switch (strict, flexible, disabled) | flexible    | Gatekeeper configuration:
| MuleConfAnypointClientId    | No       | -                    | String                              | -           | Anypoint Platform Environment Client ID
| MuleConfAnypointClientSecret| No       | -                    | String                              | -           | Anypoint Platform Environment Client ID
| MuleConfEnv                 | No       | -                    | String                              | -           | "mule.env" parameter in wrapper.conf
| MuleConfKey                 | No       | -                    | String                              | -           | "mule.key" parameter in wrapper.conf
| NTServiceName               | No       | -                    | String                              | -           | "wrapper.ntservice.name" parameter in wrapper.conf
| RegisterToken               | No       | RegisterServer       | String                              | -           | Token provided by Anypoint Runtime Manager to register a server
| ServerName                  | No       | RegisterServer       | String                              | -           | Name to identify the Mule Server in Anypint Runtime Manager
| MuleLicenseUrl              | No       | InstallMuleLicense   | String                              | -           | URL to download the Mule license provided by Mulesoft support
| AwsBucketName               | No       | -                    | String                              | False       | BucketName to download Java binaries, Mule Runtime, and Mule License. If sent, files will be downloaded from Amazon S3

## Binaries

In order to run the script an URL must be provided to download each of these binaries:
- Oracle JDK 8 Installer, OpenJDK 8, or AdoptOpenJDK 8 Zip container
- Mule Runtime 4.2.x
- Mule License provided by Mulesoft Support (Can be downloaded from the Mulesoft Help Center site)

In case of downloading the binaries through the AWS Client, the URL parameter must be a string with the S3 Object Key. For Example:

*-MuleBinaryUrl "my-s3-bucket/mule-runtime.zip"*

## Help

The script contains a help command that will provide information about the arguments:

```
> ./Mule-Runtime-Setup.ps1 -Help
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
 
  =================
  Stop Mule Service
  =================
 
    Stops the Mule Windows Service
 
    Arguments:
      -MuleHome: Path to Mule Runtime home directory
 
    i.e.: .\Mule-Runtime-Setup.ps1 -StopMuleService -MuleHome `"C:\mule\mule-enterprise-standalone-4.2.1`"
```
