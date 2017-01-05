 
 Import-Module pslogging
 $logpath = “\\FILESRV\DomainShare\admins\logs\powerShellScripts\AptSurvDBbackUp.log”
 Start-Log -LogPath “\\FILESRV\DomainShare\admins\logs\powerShellScripts\logs\” -LogName “AptSurvDBbackUp.log” -ScriptVersion “1.0” 

 #Set backup source and destination variables and script location environment
 $date = Get-Date -Format d-MMMM-yyyy 
 $nasFolder = "\\192.168.180.196\Backup\DatabaseBackup" 
 New-PSDrive -Name "Backup" -PSProvider Filesystem -Root $nasFolder 
 #$source = "\\filesrv\AptSurv\"
 $source = '\\filesrv\UpdateServicesPackages' 
 $datedFolder = "backup:\$date" 
 $path = test-Path $datedFolder 
 Write-LogInfo -LogPath $logpath -TimeStamp -ErrorAction Stop "Set backup source and destination variables and script location environment:"
  
#General Email Variables:
 $smtp = "smtp.gmail.com"
 $smtpPort = "587" 
 $from = "IITG AptSurv Backup <advtalk28@gmail.com>" 
 $to = "AMD ADMIN <alvin.vaughn@integrityitgroup.net>" 
 $subject = "Backup on $date" 
 $body = "See attached log file from AMD Database Automated backup for: $date" 
 Write-LogInfo -LogPath $logpath -TimeStamp -ErrorAction Stop "Finished setting Email Variables"

#Credentials:
#Use the CreateHashPW.ps1 to create hashed password file used in $SecureStringPassword
$EncryptedPasswordFile = '\\FILESRV\DomainShare\admins\scripts\smtpcs.txt'
$SecurePassword = Get-Content -Path $EncryptedPasswordFile | ConvertTo-SecureString
$login = "advtalk28@gmail.com"
$credentials = New-Object System.Management.Automation.Pscredential -Argumentlist $login,$SecurePassword
Write-LogInfo -LogPath $logpath -TimeStamp -ErrorAction Stop "Finished setting credential variables"

# Backup Process started 
 if ($path -eq $true) { 
    write-Host "Directory Already exists"
    Write-LogInfo -LogPath $logpath -TimeStamp "Directory Already Exist" 
    Remove-PSDrive "Backup"   
    } elseif ($path -eq $false) { 
            cd backup:\ 
            mkdir $date 
            copy-Item  -Recurse $source -Destination $datedFolder 
            $backup_log = Dir -Recurse $datedFolder | out-File "$datedFolder\AMD-DB-backup_log.txt" 
            $attachment = "$datedFolder\AMD-DB-backup_log.txt" 

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
             }                    
                Send-MailMessage @messageParameters -BodyAsHtml 
             } catch {                        
                $_ |                     
                    Out-File $env:TEMP\ProblemsSendingEmailReport.log.txt -Append -Width 1000
                    $errorOut =  $Error[0].Exception.GetType().FullName
                    Write-LogError -LogPath $logpath $errorOut                        
           } 
            cd c:\ 
 Remove-PSDrive "Backup"   
 }

Write-LogInfo -LogPath $logpath -TimeStamp -ToScreen "Task Completed"
Stop-Log -LogPath $logpath  -NoExit