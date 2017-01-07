
function preboot-msg-morning{

$stamp = Get-Date -Format d-MMMM-yyyy-HHmm
Import-Module pslogging
$logpath = “\\FILESRV\DomainShare\admins\logs\powerShellScripts\morningUpdatesMSG$stamp.log”
Start-Log -LogPath “\\FILESRV\DomainShare\admins\logs\powerShellScripts\” -LogName “morningUpdatesMSG$stamp.log” -ScriptVersion “1.0” 

#General Email Variables:
 $date = Get-Date -Format d-MMMM-yyyy
 $smtp = "smtp.gmail.com"
 $smtpPort = "587" 
 $from = "AMD ADMIN <advtalk28@gmail.com>" 
 $to = "AMD ADMIN <alvin.vaughn@integrityitgroup.net>, Alvin Vaughn <alvin@vaughns.net>" 
 $subject = "MOrning Update Message for $date" 
 $body = "See attached log file for: $date" 
 Write-LogInfo -LogPath $logpath -TimeStamp -ErrorAction Stop "Finished setting Email Variables"

#Credentials:
#Use the CreateHashPW.ps1 to create hashed password file used in $SecureStringPassword
$EncryptedPasswordFile = '\\FILESRV\DomainShare\admins\scripts\smtpcs.txt'
$SecurePassword = Get-Content -Path $EncryptedPasswordFile | ConvertTo-SecureString
$login = "advtalk28@gmail.com"
$credentials = New-Object System.Management.Automation.Pscredential -Argumentlist $login,$SecurePassword


#Get Active Directory Information: 
Import-module activedirectory
Write-LogInfo -LogPath $logpath -ToScreen "AD Module Imported"

$C=get-adcomputer -filter {OperatingSystem -NotLike "*Server*" -and Name -NotLike "*Any*"} `
-searchbase "OU=virtualpcs,OU=amdMain,DC=amd,DC=local"| ForEach-Object {$_.Name}
foreach($obj in $C) {
            $error = $null
            if (Test-Connection -ComputerName $obj -Quiet) {
                    $reachable = "Update reminder sent to " +  $obj
                    Write-LogInfo -LogPath $logpath  $reachable  
                    Invoke-command -computername $obj -scriptblock {
                        $GetUserName = [Environment]::UserName
                        $CmdMessage = { msg * 'Hello' $GetUserName  ", Reminder: Weekly backups and system updates are schedule for 8PM CST today. Please close all sessions and disconnect prior to this time."}
                        $CmdMessage | Invoke-Expression
                    } 
                } else {
                   $unreachable = $obj + "  could not be reached."
                   Write-LogWarning -LogPath $logpath  $unreachable 
                }
    }
      Write-LogInfo -LogPath $logpath -TimeStamp "Morning Message Sent"

#Send an Email to User  
            $ErrorActionPreference = "Stop"                        
        try {
            
             Write-LogInfo -LogPath $logpath ' Now emailing log file to admins'
             Stop-Log -LogPath $logpath  -NoExit     
             $messageParameters = @{                        
                            Subject = $date                        
                            Body = $body                                
                            From = $from                         
                            To =    $to                 
                            SmtpServer = $smtp
                            port = $smtpPort
                            UseSsl = $true
                            Credential = $credentials
                            Attachments = $logpath                      
             }                    
                Send-MailMessage @messageParameters -BodyAsHtml
               
             } catch {                        
                $_ | Out-File $env:TEMP\ProblemsSendingEmailReport.log.txt -Append -Width 1000
                    $errorOut =  $Error[0].Exception.GetType().FullName
                    Write-LogError -LogPath $logpath $errorOut
                    Stop-Log -LogPath $logpath  -NoExit                        
           } 



}

preboot-msg-morning

<# Tasker Script

$TaskName = "MorningUpdateMSG"
# The description of the task
$TaskDescr = "Weekly Update Message"
# The Task Action command
$TaskCommand = "powershell.exe"
# The PowerShell script to be executed
$TaskScript = '\\FILESRV\DomainShare\admins\scripts\GitHub\powershellscripts\morningUpdateMessage.ps1'
# The Task Action command argument
$TaskArg = "-WindowStyle Hidden -NonInteractive -Executionpolicy unrestricted -file $TaskScript"

 
# attach the Task Scheduler com object
$service = new-object -ComObject("Schedule.Service")
# connect to the local machine. 
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa381833(v=vs.85).aspx
$service.Connect()
$rootFolder = $service.GetFolder("\")
 
$TaskDefinition = $service.NewTask(0) 
$TaskDefinition.RegistrationInfo.Description = "$TaskDescr"
$TaskDefinition.Settings.Enabled = $true
$TaskDefinition.Settings.AllowDemandStart = $true

 
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa381841(v=vs.85).aspx
$Action = $TaskDefinition.Actions.Create(0)
$action.Path = "$TaskCommand"
$action.Arguments = "$TaskArg"
 

$TaskAction = New-ScheduledTaskAction -Execute "$TaskCommand" -Argument "$TaskArg" 
#$TaskTrigger = New-ScheduledTaskTrigger -At $TaskStartTime -Once
$trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 09:30Am 
Register-ScheduledTask -Action $TaskAction -Trigger $trigger -TaskName "$TaskName" -User "amd\amd.admin" -Password "ABCcty99##" #-RunLevel Highest




#>
