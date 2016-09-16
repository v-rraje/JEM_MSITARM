Param
(
    [Parameter(Mandatory=$true)]
    [String] $SqlServer,
    [Parameter(Mandatory=$true)]
    [String[]] $loginNames,
    [Parameter(Mandatory=$true)]
    [String] $userRole
)
    if(![string]::IsNullOrWhiteSpace($loginNames) -and ![string]::IsNullOrWhiteSpace($userRole)) 
    {
     foreach($loginName in  $loginNames)
    {
        $sqlConnection = $null
        try
        {
            $Error.Clear()

            $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
            $sqlConnection.ConnectionString = "Server=$SqlServer;Database=master;Trusted_Connection=True;"

            $Command = New-Object System.Data.SqlClient.SqlCommand
            $Command.CommandType = 1
            $Command.Connection = $sqlConnection
            $Command.CommandText = "create login [$loginName] from windows with default_database=[master], default_language=[us_english]"
            $sqlConnection.Open()
            $Command.ExecuteNonQuery() | Out-Null
            $Command.CommandText = "exec master..sp_addsrvrolemember @loginame = N'$loginName', @rolename = N'$userRole'"
            $Command.ExecuteNonQuery() | Out-Null

        }

        catch
        {
            $str = (([string] $Error).Split(':'))[1]
            Write-Error ($str.Replace('"', ''))
        }

        finally
        {
            if ($sqlConnection)
                { $sqlConnection.Close() }
        }
     }
       
   }

   $sqlConnection = $null
    try
        {
            $Error.Clear()

            $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
            $sqlConnection.ConnectionString = "Server=$SqlServer;Database=jem_data;Trusted_Connection=True;"

            $Command = New-Object System.Data.SqlClient.SqlCommand
            $Command.CommandType = 1
            $Command.Connection = $sqlConnection
            $Command.CommandText = "EXEC sp_configure 'clr enabled', 1 RECONFIGURE EXEC sp_configure 'clr enabled'"
            $sqlConnection.Open()
            $Command.ExecuteNonQuery() | Out-Null
            Write-Host "Clr Enabled.."
        }

        catch
        {
            $str = (([string] $Error).Split(':'))[1]
            #Write-Error ($str.Replace('"', ''))
        }

        finally
        {
            if ($sqlConnection)
                { $sqlConnection.Close() }
        }