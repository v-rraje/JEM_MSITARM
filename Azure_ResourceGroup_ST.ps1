<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>

param(
 [string]
 $resourceGroupName='jemdevrg3',
  
 [string]
 $StorageAccountName='jemlrssg3',
 
 [string]
 $resourceGroupLocation="West US",

 [string]
 $subscriptionId="472e0eab-03f7-40c9-a6c3-d1d493b9ee5d",

 [string]
 $deploymentName="JemDev"
)
try{
    <#
    .SYNOPSIS
        Registers RPs
    #>
    Function RegisterRP {
        Param(
            [string]$ResourceProviderNamespace
        )

        Write-Host "Registering resource provider '$ResourceProviderNamespace'";
        Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace -Force;
    }
    
    #******************************************************************************
    # Script body
    # Execution begins here
    # Connection Name: MSFT-Record-01(SPN)
    # Subscription Id: 472e0eab-03f7-40c9-a6c3-d1d493b9ee5d
    # Subscription Name: MSFT-Record-01
    # Service Principal Id: 8a2981a2-89bb-42a3-85e1-dd5dc1833cf6
    # Service Principal key: May@2016
    # Tenant Id: 72f988bf-86f1-41af-91ab-2d7cd011db47 
    #******************************************************************************

    $ErrorActionPreference = "Stop"
   
    # sign in
    Write-Host "Logging in...";
    # Login-AzureRmAccount;
    try {
    #Check if the user is already logged in for this session
    $AzureRmContext = Get-AzureRmContext | out-null
    Write-verbose “Connected to Azure”
    } catch {
    
    $user="8a2981a2-89bb-42a3-85e1-dd5dc1833cf6@microsoft.onmicrosoft.com"
    $pass = ConvertTo-SecureString "May2016^" -AsPlainText –Force
    $cred = New-Object -TypeName pscredential –ArgumentList $user, $pass
    Login-AzureRmAccount -Credential $cred -ServicePrincipal –TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47
    
    Write-verbose “logged into Azure.”
    $error.Clear()
    }
    
    # select subscription
    Write-Host "Selecting subscription '$subscriptionId'";
    Select-AzureRmSubscription -SubscriptionID $subscriptionId;

    # Register RPs
    $resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage");
    if($resourceProviders.length) {
        Write-Host "Registering resource providers"
        foreach($resourceProvider in $resourceProviders) {
            RegisterRP($resourceProvider);
        }
    }

    #Create or check for existing resource group
    $resourceGroup = Get-AzureRmResourceGroup -Name "$resourceGroupName" -ErrorAction SilentlyContinue
    if(!$resourceGroup)
    {
        Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
        if(!$resourceGroupLocation) {
            $resourceGroupLocation = Read-Host "resourceGroupLocation";
        }
        Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
        New-AzureRmResourceGroup -Name "$resourceGroupName" -Location $resourceGroupLocation
    }
    else{
        Write-Host "Using existing resource group '$resourceGroupName'";
    }

    # Start the deployment -Procuring Storage Account.
    Write-Host "Starting deployment For Storage Account Creation For '$StorageAccountName'";

    $StorageAccount = @{
        ResourceGroupName = $resourceGroupName;
        Name = $StorageAccountName;
        SkuName = 'Standard_LRS';
        Location = $resourceGroupLocation;#TODO : check for the location.
        }

    $storageAcc=Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
    if (!$storageAcc.StorageAccountName)
    {  
       Write-Host "Creating Storage Account... $StorageAccountName"
       New-AzureRmStorageAccount @StorageAccount;
     }
     else
     {
     Write-Host "Taking already existing Storage Account: '$StorageAccountName' from  Resource Group: '$resourceGroupName' "
     }
}
catch [System.Exception]
{
	$tryError = $_.Exception
	$message = $tryError.Message
	Write-Host "Unable to configure it on server-$RemoteComputers. Error: $message."
    break
}