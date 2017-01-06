
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
                   Invoke-command -computername $obj -scriptblock {msg * "Weekly Updates are scheduled for installation soon. All sessions are scheduled for disconnect at 8:00pm today."} 
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

