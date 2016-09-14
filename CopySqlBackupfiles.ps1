 Param
(
[Parameter(Mandatory=$true)]
[String]
$sqlServer
)

Robocopy  "\\azcujemdeviis02\Jem_ARM_V6_Bits\DataBase" "\\$sqlServer\E$\MSSQL11.MSSQLSERVER\MSSQL\Backup" /e
