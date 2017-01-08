function get-aptsessions() {
    
    Import-Module pslogging
    $stamp = Get-Date -Format d-MMMM-yyyy-HHmm
    $logpath = “\\FILESRV\DomainShare\admins\logs\powerShellScripts\AptSurvDisconnect$stamp.log”
    Start-Log -LogPath “\\FILESRV\DomainShare\admins\logs\powerShellScripts\” -LogName “AptSurvDisconnect$stamp.log” -ScriptVersion “1.0” 

    #General Email Variables:
     $date = Get-Date -Format d-MMMM-yyyy-HHmm 
     $smtp = "smtp.gmail.com"
     $smtpPort = "587" 
     $from = "AMD IT ADMIN <advtalk28@gmail.com>" 
     $to = "IITG AMD PM <alvin.vaughn@integrityitgroup.net>, Alvin Vaughn <alvin@vaughns.net>" 
     $cc = "Alvin Work <alvin.vaughn@harrishealth.org>"
     $subject = "Disconnected AptSurv Sessions on $date" 
     $body = "See attached log file for: $date" 
     Write-LogInfo -LogPath $logpath -TimeStamp -ErrorAction Stop "Finished setting Email Variables"

    #Credentials:
    #Use the CreateHashPW.ps1 to create hashed password file used in $SecureStringPassword
    $EncryptedPasswordFile = '\\FILESRV\DomainShare\admins\scripts\filesrvsmtpcs.txt'
    $SecurePassword = Get-Content -Path $EncryptedPasswordFile | ConvertTo-SecureString
    $login = "advtalk28@gmail.com"
    $credentials = New-Object System.Management.Automation.Pscredential -Argumentlist $login,$SecurePassword

        Get-SmbOpenFile | where {$_.Path -like '*Apt*'} | Sort-Object  sessionid -Unique  |Foreach-Object {

            $session = $_
            $clients = Get-SmbSession | where {$_.ClientComputerName -eq $session.ClientComputerName} 

       
         New-Object -TypeName PSObject -Property @{
                SessionID = $clients.SessionId  
                User = $clients.ClientUserName
                Computer =  $clients.ClientComputerName
            } 

         # $logDisconnects
          $logDisconnects = $clients.ClientUserName + ' on computer '+ $clients.ClientComputerName + ' disconnected.'
          #Write-LogInfo -LogPath $logpath $logDisconnects
          #Close-SmbSession $clients.SessionId 


            if (Close-SmbSession $clients.SessionId -Force  ) {
                     Write-LogInfo -LogPath $logpath $logDisconnects
                } else {
                   $unreachable = $clients.ClientComputerName + ' on computer ' + $clients.ClientComputerName + "  could not be reached."
                   Write-LogWarning -LogPath $logpath  $unreachable
                   $_ | Out-File $logpath -Append ascii -Width 100
                }




        }    |Format-Table -AutoSize  
       
      Write-LogInfo -LogPath $logpath -TimeStamp "Disconnect Task Completed"
      #Stop-Log -LogPath $logpath  -NoExit

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
                    Stop-Log -LogPath $logpath  #-NoExit                        
           } 



    } 
   

get-aptsessions

<# Tasker Script

$TaskName = "AMD Database Disconnect MSG"
# The description of the task
$TaskDescr = "Announce Weekly Disconnects prior to AMD Database Backup"
# The Task Action command
$TaskCommand = "powershell.exe"
# The PowerShell script to be executed
$TaskScript = '\\FILESRV\DomainShare\admins\scripts\GitHub\powershellscripts\filesrv\AptSessions.ps1'
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
$trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 07:45Pm 
Register-ScheduledTask -Action $TaskAction -Trigger $trigger -TaskName "$TaskName" -User "amd\amd.admin" -Password "ABCcty99##" #-RunLevel Highest

#>
