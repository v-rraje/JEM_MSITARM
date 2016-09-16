Param
(
[Parameter(Mandatory=$true)]
[String[]]
$RemoteComputers,
[Parameter(Mandatory=$true)]
[String[]]
$folderPaths,
[Parameter(Mandatory=$true)]
[String[]]
$keyValues
)
function FindAndReplace ($folderPaths,$keyValues) {

$lookupTable = ConvertFrom-StringData ($keyValues | out-string)
foreach ($folderPath in $folderPaths)
 { 
 $configFiles = Get-ChildItem $folderPath *.config -rec
    foreach ($original_file in $configFiles)
    {
     (Get-Content  $original_file.PSPath) | ForEach-Object { 
        $line = $_
        $lookupTable.GetEnumerator() | ForEach-Object {
            if ($line -match $_.Key)
            {
                $line = $line -replace $_.Key, $_.Value
            }
        }
       $line
    } | Set-Content $original_file.PSPath
   }
  }
}
foreach ($RemoteComputer in $RemoteComputers)
 { 
Invoke-Command -ComputerName $RemoteComputer -ScriptBlock ${function:FindAndReplace} -ArgumentList $folderPaths,$keyValues -ErrorAction Continue
}