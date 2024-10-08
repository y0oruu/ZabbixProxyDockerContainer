$proxyname = Read-Host "Name of proxy : "

function Get-Key {
    $openssInstalled = choco list | Select-String "openssl"
    if($openssInstalled -like "openssl*") {
       Write-Host "OpenSSL is already installed"
    }
       else  
       {
          Write-Host "OpenSSL is not yet installed, installing..."
          choco install openssl -y
       }
    $pskKey = & "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" rand -hex 32
    $pskKey | Set-Content -Path 'C:\proxyzabbix\key\zabbix_proxy_psk' // modify path according to your path
   } 

# Replacing docker compose variables

#(Get-Content "C:\proxyzabbix\docker-compose.yml").Replace('###proxy-name###', $env:proxy_name) | Set-Content "C:\proxyzabbix\docker-compose.yml" // modify path according to your path
(Get-Content "C:\proxyzabbix\docker-compose.yml").Replace("###proxy-name###", $proxyname) | Set-Content "C:\proxyzabbix\d-compose\docker-compose.yml" // modify path according to your path
# Verify if a key already exists
If (Test-Path -Path C:\proxyzabbix\key\zabbix_proxy_psk) { // modify path according to your path
    Write-Host "The PSK exists"
} Else {
    Write-Host "The PSK does not exist"
    
    # Generate a key if no key are found
    Get-Key
}

# Start docker container 
wsl --exec dbus-launch true 
wsl.exe -d Ubuntu -u "user" cp /mnt/c/proxyzabbix/d-compose/docker-compose.yml ~/docker/docker-compose.yml // modify path according to your path
wsl.exe -d Ubuntu -u "user" docker compose -f ~/docker/docker-compose.yml up -d // modify path according to your path

Remove-Item "C:\proxyzabbix\d-compose\docker-compose.yml" // modify path according to your path
