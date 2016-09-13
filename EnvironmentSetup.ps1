 Param
(
[Parameter(Mandatory=$true)]
[String]
$iisAppPoolName,
[Parameter(Mandatory=$true)]
[String]
$ServiceAccountName,
[Parameter(Mandatory=$true)]
[String]
$ServiceAccountPwd,
[Parameter(Mandatory=$true)]
[String]
$iisWebSiteName,
[AllowEmptyCollection()]
[String[]]
$iisAppNames,
[AllowEmptyCollection()]
[String[]]
$servicePaths,
[string]
$IsQueueEnabled=0,
[AllowEmptyCollection()]
[String[]]
$QueueNames
)

try
{
# Following modifies the Write-Verbose behavior to turn the messages on globally for this session
$VerbosePreference = "Continue"

$directoryPath="E:\inetpub\wwwroot\$iisWebSiteName"

Import-Module WebAdministration

$site = Get-Item 'IIS:\sites\Default Web Site'
$site.serverAutoStart = $False
$site.Stop()

#Navigate to the app pools root
cd IIS:\AppPools\

#Check if the app pool exists
if (!(Test-Path $iisAppPoolName -PathType container))
{
    write-host "Creating App pool..."
    #create the app pool
    $appPool = New-Item $iisAppPoolName
    $appPool.processmodel.identityType= 3
    $appPool.processModel.userName = $ServiceAccountName
    $appPool.processModel.password = $ServiceAccountPwd
    $appPool | Set-Item
    #$appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
}
else
{
write-host "App pool already created..."
}

#Navigate to the sites root
cd IIS:\Sites\

#Check if the site exists
if (!(Test-Path $iisWebSiteName -pathType container))
{
    #Create the site.
    write-host "Creating Web site ..."
    #TODO : Dns Mapping should be handled and host name and binding information should be updated appropritatly.
    $iisApp = New-Item $iisWebSiteName -bindings @{protocol="http";bindingInformation=":80:"} -physicalPath $directoryPath
    $iisApp | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName
}
else
{
write-host "Web site already created..."
}

#Unlock Section.
Set-WebConfiguration /system.webServer/security/authentication/anonymousAuthentication  MACHINE/WEBROOT/APPHOST -Metadata overrideMode -Value Allow
Set-WebConfiguration /system.webServer/security/authentication/windowsAuthentication  MACHINE/WEBROOT/APPHOST -Metadata overrideMode -Value Allow
Set-WebConfiguration /system.webServer/security/authentication/basicAuthentication  MACHINE/WEBROOT/APPHOST -Metadata overrideMode -Value Allow

#Disable the anonymous Authentication
Set-WebConfigurationProperty -Filter "/system.WebServer/security/authentication/AnonymousAuthentication" -Name Enabled -Value False -PSPath "$iisWebSiteName" -ErrorAction SilentlyContinue
#Enable the windows Authentication
Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/windowsAuthentication" -Name Enabled -Value True -PSPath "$iisWebSiteName" -ErrorAction SilentlyContinue

# Create Web applications under website.
$appPath = "IIS:\Sites\$iisWebSiteName\";

foreach($iisAppName in $iisAppNames)
{
    if((Get-WebApplication -Name $iisAppName) -eq $null -and (Test-Path $appPath$iisAppName) -eq $true)
    {
        write-host "Creating Web Application ..."
        ConvertTo-WebApplication -ApplicationPool $iisAppPoolName $appPath$iisAppName;
    }
    else
    {
        echo "$iisAppName Already exists...";
    }
}

#Configure All Windows Services.
foreach($servicePath in $servicePaths)
{
    $binaryPath,$serviceName = $servicePath.split(';',2)

    # verify if the service already exists, and if yes remove it first
    if (Get-Service $serviceName -ErrorAction SilentlyContinue)
    {
	    # using WMI to remove Windows service because PowerShell does not have CmdLet for this
        $serviceToRemove = Get-WmiObject -Class Win32_Service -Filter "name='$serviceName'"
        $serviceToRemove.delete()
        "Service removed..."
    }
    else
    {
	    # just do nothing
        write-host "Service does not exists..."
    }

    "Installing service started..."
    # creating credentials which can be used to run my windows service
    $secpasswd = ConvertTo-SecureString $ServiceAccountPwd -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($ServiceAccountName, $secpasswd)

    # creating widnows service using all provided parameters
    New-Service -name $serviceName -binaryPathName $binaryPath -displayName $serviceName -startupType Automatic -credential $mycreds
    "Installation completed..."
}
 
foreach($QueueName in $QueueNames)
{
    [Reflection.Assembly]::LoadWithPartialName('System.Messaging')
    $msmq = [System.Messaging.MessageQueue]
    $queuePath = ".\private$\$QueueName"  
    if($msmq::Exists($queuePath))
    {
        Write-Host "$queuePath already exists..."
    }
    else
    {
        Write-Host "'$queuePath' doesn't exists and now to create ..."
        $newQueue = $msmq::Create($queuePath,'true')
        $newQueue.Label = $queuePath
        $newQueue.UseJournalQueue = $True
        #Default to everyone if no user is specified
        $newQueue.SetPermissions(
        "Everyone",[System.Messaging.MessageQueueAccessRights] "ReceiveMessage, PeekMessage, DeleteQueue, GetQueueProperties, GetQueuePermissions")
        Write-Host "Private queue '$queuePath' has been created..."
    }
}
}
catch [System.Exception]
{
	$tryError = $_.Exception
	$message = $tryError.Message
	Write-CustomLog -Error -Hostoutput ("Unable to configure it on server . Error: $message.")
    break
}
