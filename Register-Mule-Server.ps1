 function RegisterMuleServer(
  [Parameter(Mandatory=$true)][string]$MuleHome,
  [Parameter(Mandatory=$true)][string]$RegisterToken, 
  [Parameter(Mandatory=$true)][string]$ServerName) {
  
  Write-Host ""
  Write-Host "===================="
  Write-Host "Register Mule Server"
  Write-Host "===================="

  cd "$($MuleHome)\bin\";

  Write-Host "`r`n[SETUP] Register Mule server with name: $ServerName to Anypoint Runtime Manager with the token: $RegisterToken";

  ./amc_setup -H "$RegisterToken" "$ServerName" | Write-Host;
  
} 
