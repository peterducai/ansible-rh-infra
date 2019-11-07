$treshold=90
write "minimum free space must be more than $treshold %"
Get-CimInstance  win32_logicaldisk | 
foreach-object {  write "
$($_.caption)  $('{0:N0}' -f $($('{0:N0}' -f ($_.FreeSpace/1gb))/$('{0:N0}' -f ($_.Size/1gb))*100))"
if ($($($_.FreeSpace/$_.Size)*100) -lt $treshold) {write "ERROR"} else {write "OK"}
}
