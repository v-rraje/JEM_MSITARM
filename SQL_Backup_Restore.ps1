Param
(
    [Parameter(Mandatory=$true)]
    [String] $SqlServer,
    [Parameter(Mandatory=$true)]
    [String] $dbname,
    [String] $PathToBackup,
    [String] $PathToRestoreFrom,
    [String] $Restore, #If restore is set to 1 then restore will happen.
    [String] $Backup #If restore is set to 1 then Backup will happen.
)
# The script has been tested on Powershell 3.0
Set-StrictMode -Version 3

# Following modifies the Write-Verbose behavior to turn the messages on globally for this session
$VerbosePreference = "Continue"

# Check if Windows SQL Powershell is avaiable

$dt = Get-Date -Format yyyyMMddHHmmss
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

IF($Backup -eq 1 ) 
{
#Backup
	Backup-SqlDatabase -ServerInstance $SqlServer -Database $dbname -BackupFile $PathToBackup -ConnectionTimeout 0
#Restore with overwrite
}

IF($Restore -eq 1 ) 
{
    IF([string]::IsNullOrWhiteSpace($PathToRestoreFrom) ) 
    {
        throw "parameter $PathToRestoreFrom cannot be empty"
    }
    Restore-SqlDatabase -ServerInstance $SqlServer -Database $dbname -BackupFile $PathToRestoreFrom -ReplaceDatabase -ConnectionTimeout 0
}