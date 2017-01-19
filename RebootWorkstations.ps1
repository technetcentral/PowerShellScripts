


function RebootPC{

$stamp = Get-Date -Format d-MMMM-yyyy-HHmm
Import-Module pslogging
$logpath = “\\FILESRV\DomainShare\admins\logs\powerShellScripts\RebootPC$stamp.log”
Start-Log -LogPath “\\FILESRV\DomainShare\admins\logs\powerShellScripts\” -LogName “RebootPC$stamp.log” -ScriptVersion “1.0” 

#General Email Variables:
 $date = Get-Date -Format d-MMMM-yyyy
 $smtp = "smtp.gmail.com"
 $smtpPort = "587" 
 $from = "AMD ADMIN <advtalk28@gmail.com>" 
 $to = "AMD ADMIN <alvin.vaughn@integrityitgroup.net>, Alvin Vaughn <alvin@vaughns.net>"
 $cc = "Alvin Work <alvin.vaughn@harrishealth.org>" 
 $subject = "$date Virtual PC Reboot" 
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
#-and Name -NotLike "*Any*"
$C=get-adcomputer -filter {OperatingSystem -NotLike "*Server*" } | `
#-searchbase "OU=virtualpcs,OU=amdMain,DC=amd,DC=local"| 
ForEach-Object {$_.Name}
foreach($obj in $C) {
            $error = $null
            if (Test-Connection -ComputerName $obj -Quiet) {
                    $reachable = "Reboot Message sent to " +  $obj
                    Write-Host  $reachable
                     Write-LogInfo -LogPath $logpath $reachable  
                   
                    Invoke-command -computername $obj -scriptblock {
shutdown -r -f -t 60 -c  " Your system will reboot in 1 min. Please close all your work and disconnec"
          
                    }
                     
                } else {
                   $unreachable = $obj + "  could not be reached."
                   Write-Host  $unreachable
                    Write-LogWarning -LogPath $logpath $unreachable 
                }
    }
      

#Send an Email  
            $ErrorActionPreference = "Stop"                        
        try {
            
             Write-LogInfo -LogPath $logpath ' Now emailing log file to admins'
             Stop-Log -LogPath $logpath  -NoExit     
             $messageParameters = @{                        
                            Subject = $date                        
                            Body = $body                                
                            From = $from                         
                            To =    $to
                            cc = $cc                 
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

RebootPC

<# Tasker Script

$TaskName = "AMD Database Backup MSG"
# The description of the task
$TaskDescr = "Announce Weekly AMD Database Backup"
# The Task Action command
$TaskCommand = "powershell.exe"
# The PowerShell script to be executed
$TaskScript = '\\FILESRV\DomainShare\admins\scripts\GitHub\powershellscripts\AptWeeklyBackUpMessage.ps1'
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
$trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 05:00Pm 
Register-ScheduledTask -Action $TaskAction -Trigger $trigger -TaskName "$TaskName" -User "amd\amd.admin" -Password "ABCcty99##" #-RunLevel Highest

#>
