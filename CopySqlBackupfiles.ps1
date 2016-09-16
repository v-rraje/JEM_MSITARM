 Param
(
[Parameter(Mandatory=$true)]
[String]
$sqlServer
)

Robocopy  "\\azcujemdeviis02\Jem_ARM_V6_Bits\DataBase" "\\$sqlServer\E$\MSSQL12.MSSQLSERVER\MSSQL\bak" /e