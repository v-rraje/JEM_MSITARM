# Name: DeployWebServer
#
Configuration DeployWebServer
{
  param (  
  [string[]]$MachineName = "localhost"
  )

  Node localhost
  {
	   
    foreach ($Feature in @("Web-Server", `
                           "Web-App-Dev", `
                           "Web-Asp-Net45", `
                           "Web-Net-Ext45", `
                           "Web-Ftp-Server", `
                           "Web-Mgmt-Compat", `
                           "Web-ISAPI-Ext", `
                           "Web-ISAPI-Filter", `
                           "Web-Log-Libraries", `
                           "Web-Request-Monitor", `
                           "Web-Mgmt-Tools", `
                           "Web-Mgmt-Console", `
                           "WAS", `
                           "WAS-Process-Model", `
                           "WAS-Config-APIs",`
                           "NET-HTTP-Activation",`      
                           "NET-Non-HTTP-Activ" ,`       
                           "NET-WCF-HTTP-Activation45" ,`
                           "NET-WCF-MSMQ-Activation45" ,`
                           "NET-WCF-Pipe-Activation45" ,`
                           "NET-WCF-TCP-Activation45"  ,`
                           "NET-WCF-TCP-PortSharing45")){            
        WindowsFeature "$Feature$Number"{  
                        Ensure = “Present”  
                        Name = $Feature  
        } 
    } 

       
	    
  }

}

