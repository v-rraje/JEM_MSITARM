# sourced from GetCurrentDirectory.ps1
$directoryPath = Get-Location
Set-Variable -name currentpath -Value $directoryPath.path

try
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
    install-windowsfeature web-webserver -IncludeManagementTools
    install-WindowsFeature web-dyn-compression -IncludeManagementTools
    install-WindowsFeature Web-Basic-Auth -IncludeManagementTools
    install-WindowsFeature Web-Windows-Auth -IncludeManagementTools
    install-WindowsFeature Web-App-Dev -IncludeManagementTools
    install-WindowsFeature Web-Net-Ext45 -IncludeManagementTools
    install-WindowsFeature Web-AppInit -IncludeManagementTools
    install-WindowsFeature Web-ASP -IncludeManagementTools
    install-WindowsFeature Web-Asp-Net45 -IncludeManagementTools
    install-WindowsFeature Web-Includes -IncludeManagementTools
    install-WindowsFeature Web-WebSockets -IncludeManagementTools
    install-WindowsFeature Web-Scripting-Tools -IncludeManagementTools
    install-WindowsFeature NET-WCF-HTTP-Activation45 -IncludeManagementTools

    # Now, Application Server configuration
    install-WindowsFeature Application-Server -IncludeManagementTools
    install-WindowsFeature AS-Dist-Transaction -IncludeManagementTools
    install-WindowsFeature AS-Incoming-Trans -IncludeManagementTools
    install-WindowsFeature AS-Outgoing-Trans -IncludeManagementTools
    install-WindowsFeature AS-TCP-Port-Sharing -IncludeManagementTools
    install-WindowsFeature AS-Web-Support -IncludeManagementTools
    install-WindowsFeature AS-TCP-Port-Sharing -IncludeManagementTools
    install-WindowsFeature AS-HTTP-Activation  -IncludeManagementTools
    install-WindowsFeature MSMQ
    install-WindowsFeature Web-Windows-Auth -IncludeManagementTools;

    # Disable windows firewall for good measure. We'll turn back on afterwards.
    Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False

    Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True
}
catch [Exception]
{
    throw
}
