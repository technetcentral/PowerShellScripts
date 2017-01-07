function preboot-amd{

#$CMD=Read-host -prompt "enter a command to run on all STO workstations (for cmd line only items enter cscript `"some command`")"
$CMD="Weekly Updates are scheduled for installation soon. Sessions will be disconnected in less than 15 mins, please close the database. "
Import-module activedirectory
$C=get-adcomputer -filter {OperatingSystem -NotLike "*Server*" -and Name -NotLike "*Any*"} 
-searchbase "OU=virtualpcs,OU=amdMain,DC=amd,DC=local"| ForEach-Object {$_.Name}
foreach($obj in $C) {
            Write-Host $obj
            #Invoke-command -computername $obj -scriptblock {$CMD}
            $CMD
            }

}