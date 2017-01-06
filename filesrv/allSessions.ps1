function get-allSessions() {
    
    Import-Module pslogging
    $logpath = “\\FILESRV\DomainShare\admins\logs\powerShellScripts\AllSessionDisconnect.log”
    Start-Log -LogPath “\\FILESRV\DomainShare\admins\logs\powerShellScripts\” -LogName “AllSessionDisconnect.log” -ScriptVersion “1.0” 
##############################################################################################################################################   
 #Set Send-MailMessage Email Variables:
 $date = Get-Date -Format d-MMMM-yyyy  
 $smtp = "smtp.gmail.com"
 $smtpPort = "587" 
 $from = "AMD Session Disconnect Log <advtalk28@gmail.com>" 
 $to = "AMD ADMIN <alvin.vaughn@integrityitgroup.net>, , Alvin Mobile <9109644152@tmomail.net>" 
 $subject = "Backup on $date" 
 $body = "See attached log file from AMD Database Automated backup for: $date"
 $attachment = "\\FILESRV\DomainShare\admins\logs\powerShellScripts\AllSessionDisconnect.log" 
 Write-LogInfo -LogPath $logpath -TimeStamp -ErrorAction Stop "Finished setting Send-MailMessage Variables"
 
 
#Credentials:
#Use the CreateHashPW.ps1 to create hashed password file used in $SecureStringPassword
$EncryptedPasswordFile = '\\FILESRV\DomainShare\admins\scripts\filesrvsmtpcs.txt'
$SecurePassword = Get-Content -Path $EncryptedPasswordFile | ConvertTo-SecureString
$login = "advtalk28@gmail.com"
$credentials = New-Object System.Management.Automation.Pscredential -Argumentlist $login,$SecurePassword
Write-LogInfo -LogPath $logpath -TimeStamp -ErrorAction Stop "Finished setting SMTP credential variables"
############################################################################################################################################## 

 Get-SmbOpenFile  | Sort-Object  sessionid -Unique  |Foreach-Object {

            $session = $_
            $clients = Get-SmbSession | where {$_.ClientComputerName -eq $session.ClientComputerName} 
       
         New-Object -TypeName PSObject -Property @{
                SessionID = $clients.SessionId  
                User = $clients.ClientUserName
                Computer =  $clients.ClientComputerName
            } 

          $logDisconnects
          $logDisconnects = $clients.ClientUserName + ' on computer '+ $clients.ClientComputerName + ' disconnected.'
          Write-LogInfo -LogPath $logpath $logDisconnects -TimeStamp -ToScreen
          #Close-SmbSession $clients.SessionId -Force

        }    |Format-Table -AutoSize   
      Write-LogInfo -LogPath $logpath -TimeStamp -ToScreen "Disconnect Task Completed"
      Stop-Log -LogPath $logpath  -NoExit
##############################################################################################################################################


#Send an Email to User  
            $ErrorActionPreference = "Stop"                        
        try {    
             $messageParameters = @{                        
                            Subject = $date                        
                            Body = $body                                
                            From = $from                         
                            To =    $to                 
                            SmtpServer = $smtp
                            port = $smtpPort
                            UseSsl = $true
                            Credential = $credentials
                            Attachments = $attachment
                                                  
             }                    
                Send-MailMessage @messageParameters -BodyAsHtml 
             } catch {                        
                $_ | Out-File “\\FILESRV\DomainShare\admins\logs\powerShellScripts\ProblemsSendingEmailReport.txt" -Append -Width 1000
                    #$errorOut =  $Error[0].Exception.GetType().FullName
                    #Write-LogError -LogPath $logpath $errorOut                        
           } 
    } 

get-allSessions