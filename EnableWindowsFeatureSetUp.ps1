 Param
(
[String[]]
$RemoteComputers,
[String]
$UserName='fareast\v-rraje',
[String]
$PassWord='Aug2016^',
[int]
$WaitTime=60  # Every half an hour it will check for server availablity.
)
function InstallComponents ()
{
    # Install WebPI.
    $webpifile = “C:\WebPlatformInstaller_amd64_en-US.msi”
    $webplatformdownload = “http://download.microsoft.com/download/7/0/4/704CEB4C-9F42-4962-A2B0-5C84B0682C7A/WebPlatformInstaller_amd64_en-US.msi"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($webplatformdownload, $webpifile)
    Start-Process $webpifile /qn -Wait

    # now use it to install ARRv3_0 and its dependencies
    & 'C:\Program Files\Microsoft\Web Platform Installer\WebpiCmd.exe' /Install /Products:ARRv3_0 /accepteula /suppressreboot

    # Next, install Windows Features. First, Web Server configuration
    Install-WindowsFeature web-webserver -IncludeManagementTools
    Install-WindowsFeature web-dyn-compression -IncludeManagementTools
    Install-WindowsFeature Web-Basic-Auth -IncludeManagementTools
    Install-WindowsFeature Web-Windows-Auth -IncludeManagementTools
    Install-WindowsFeature Web-App-Dev -IncludeManagementTools
    Install-WindowsFeature Web-Net-Ext45 -IncludeManagementTools
    Install-WindowsFeature Web-AppInit -IncludeManagementTools
    Install-WindowsFeature Web-ASP -IncludeManagementTools
    Install-WindowsFeature Web-Asp-Net45 -IncludeManagementTools
    Install-WindowsFeature Web-Includes -IncludeManagementTools
    Install-WindowsFeature Web-WebSockets -IncludeManagementTools
    Install-WindowsFeature Web-Scripting-Tools -IncludeManagementTools
    Install-WindowsFeature NET-WCF-HTTP-Activation45 -IncludeManagementTools

    # Now, Application Server configuration
    Install-WindowsFeature Application-Server -IncludeManagementTools
    Install-WindowsFeature AS-Dist-Transaction -IncludeManagementTools
    Install-WindowsFeature AS-Incoming-Trans -IncludeManagementTools
    Install-WindowsFeature AS-Outgoing-Trans -IncludeManagementTools
    Install-WindowsFeature AS-TCP-Port-Sharing -IncludeManagementTools
    Install-WindowsFeature AS-Web-Support -IncludeManagementTools
    Install-WindowsFeature AS-TCP-Port-Sharing -IncludeManagementTools
    Install-WindowsFeature AS-HTTP-Activation  -IncludeManagementTools
    Install-WindowsFeature MSMQ
    Install-WindowsFeature Web-Windows-Auth -IncludeManagementTools;

    # Disable windows firewall for good measure. We'll turn back on afterwards.
    Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False

    Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True
}

$cnt=0
while(1)
{
   foreach ($RemoteComputer in $RemoteComputers) { 
        if (test-Connection -ComputerName $RemoteComputer -Quiet ) 
        {  
            $cnt =$cnt+1
            Write-Host $RemoteComputer " is alive and Pinging "  -ForegroundColor Green
        } 
        else 
        {
            Write-Warning $RemoteComputer " seems dead not pinging " 
        }     
   } 
   
   if($cnt -ne $RemoteComputers.Length)
   { 
        $cnt=0
        Write-Host 'Sleept...'
        start-sleep -seconds $WaitTime
        Write-Host 'WakeUp...'
   }
   else
   {
        Write-Host $RemoteComputers " all the servers are alive " 
        break;
   }
}

$PassWordEnc = convertto-securestring $PassWord -asplaintext -force
$MyCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName,$PassWordEnc

foreach($cmp in $RemoteComputers)
{
Invoke-Command -ComputerName $cmp -ScriptBlock ${function:InstallComponents} -Credential $MyCred -ErrorAction Continue
}

Start-Sleep -s 10
