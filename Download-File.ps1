 function DownloadFromAws( 
  [Parameter(Mandatory=$true)][string]$FileUrl, 
  [Parameter(Mandatory=$true)][string]$FilePath,
  [Parameter(Mandatory=$true)][string]$AwsBucketName) {
    
    Write-Host "`r`n[SETUP] Download file from S3 Bucket: $AwsBucketName. File: $FileUrl. To: $FilePath"

    Copy-S3Object -BucketName "$AwsBucketName" -Key "$FileUrl" -LocalFile $FilePath | Write-Host;

    return $FilePath;
}

function DownloadFromUrl(
  [Parameter(Mandatory=$true)][string]$FileUrl,
  [Parameter(Mandatory=$true)][string]$FilePath) {
  Write-Host "`r`n[SETUP] Download from $FileUrl To: $FilePath. Please wait"

  $ProgressPreference = 'SilentlyContinue'
  Invoke-WebRequest "$FileUrl"  -OutFile "$FilePath"
  
  return $FilePath;
}

function DownloadFile(
  [Parameter(Mandatory=$true)][string]$FileUrl, 
  [Parameter(Mandatory=$true)][string]$FileDirectory,
  [string]$AwsBucketName) {
  
  $FileName = [System.IO.Path]::GetFileName($FileUrl)
  $FilePath = "$($FileDirectory)\$($FileName)"
  
  if($AwsBucketName) {
    return DownloadFromAws -FileUrl "$FileUrl" -FilePath "$FilePath" -AwsBucketName "$AwsBucketName";
  } else {
    return DownloadFromUrl -FileUrl "$FileUrl" -FilePath "$FilePath";
  }
} 
