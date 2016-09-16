Param
(
    [String] $SqlServer,
    [String] $dbname,
    [String] $Restore, #If restore is set to 1 then restore will happen.
    [String] $Backup #If backup is set to 1 then Backup will happen.
    
)
    # Following modifies the Write-Verbose behavior to turn the messages on globally for this session
    $VerbosePreference = "Continue"

    #$dt = Get-Date -Format yyyyMMddHHmmss
    IF([string]::IsNullOrWhiteSpace($SqlServer) ) 
    {
        throw "parameter $SqlServer cannot be empty"
    }
    IF([string]::IsNullOrWhiteSpace($dbname) ) 
    {
        throw "parameter $dbname cannot be empty"
    }
    IF([string]::IsNullOrWhiteSpace($Restore) ) 
    {
        $Restore = 0
    }
    IF([string]::IsNullOrWhiteSpace($Backup) ) 
    {
        $Backup = 0
    }
    
    $paths = @("H:\MSSQL11.MSSQLSERVER\MSSQL\DATA","E:\MSSQL11.MSSQLSERVER\MSSQL\DATA","O:\MSSQL11.MSSQLSERVER\MSSQL\DATA","H:\MSSQL12.MSSQLSERVER\MSSQL\DATA","E:\MSSQL12.MSSQLSERVER\MSSQL\DATA","O:\MSSQL12.MSSQLSERVER\MSSQL\DATA")
    
    foreach($path in  $paths)
    {
        if((Test-Path $path) -eq 0)
        {
           new-item $path -itemtype directory
        }
    }

    IF($Backup -eq 1 ) 
    {
    #Backup
    #Backup-SqlDatabase -ServerInstance $SqlServer -Database $dbname -BackupFile $PathToBackup -ConnectionTimeout 0
    OSQL -S $SqlServer -E -Q "BACKUP DATABASE $dbname TO DISK = 'E:\MSSQL11.MSSQLSERVER\MSSQL\bak\$dbname.bak' WITH INIT"  
    #Restore with overwrite
    }

    IF($Restore -eq 1 ) 
    {
    write-host 'asda'
    #OSQL -S 'azfjemsql02' -E -Q "RESTORE DATABASE sp1 FROM DISK = 'E:\MSSqlServer\MSSQL\Backup\sp1.bak' WITH MOVE 'sp1' TO 'H:\MSSqlServer\MSSQL\DATA\sp1.mdf',MOVE 'sp1_Log' TO 'O:\MSSqlServer\MSSQL\DATA\sp1_Log.ldf'"
    OSQL -S $SqlServer -E -Q "RESTORE DATABASE $dbname FROM DISK = 'E:\MSSQL12.MSSQLSERVER\MSSQL\bak\$dbname.bak' WITH REPLACE, RECOVERY, MOVE '$dbname' TO 'H:\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.mdf',MOVE '$($dbname)_Log' TO 'H:\MSSQL12.MSSQLSERVER\MSSQL\DATA\$($dbname)_Log.ldf'"
    }
