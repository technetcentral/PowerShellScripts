﻿
 
 $date = Get-Date -Format d-MMMM-yyyy 
 $smtp = "smtp.gmail.com"
 $smtpPort = "587" 
 $from = "IITG Email Script Template <advtalk28@gmail.com>" 
 $to = "Alvin Vaughn <alvin.vaughn@outlook.com>" 
 $body = "This is a test log created on: $date" 
 $subject = "Test Log Capture Email on $date" 
 $EncryptedPasswordFile = '\\FILESRV\DomainShare\admins\scripts\smtpcs.txt'


#Use the CreateHashPW.ps1 to create hashed password file used in $SecureStringPassword
$SecureStringPassword = Get-Content -Path $EncryptedPasswordFile | ConvertTo-SecureString
$login = "advtalk28@gmail.com"
$credentials = New-Object System.Management.Automation.Pscredential -Argumentlist $login,$SecureStringPassword

 $messageParameters = @{                        
                Subject = "Test Email - $((Get-Date).ToShortDateString())"                        
                Body = "This is a test log created on: $date"                                
                From = "IITG Email Script Template <advtalk28@gmail.com>"                         
                To =    "Alvin Vaughn <alvin.vaughn@outlook.com>"                 
                SmtpServer = $smtp
                port = $smtpPort
                UseSsl = $true
                Credential = $credentials                      
            }                        
            Send-MailMessage @messageParameters -BodyAsHtml 

#Send an Email should go at bottom of script file as the last action to perform  
send-MailMessage -SmtpServer $smtp -port $smtpPort -UseSsl -From $from -To $to -Credential $Credentials -Subject $subject  -Body $body -BodyAsHtml  

<# Additional parameters: 
 -Credential (Get-credential)
 -Attachments $attachment 

 $path = '\\vfs04\Users$\vaugha1\Documents'
 $backup_log = Dir -Recurse $destination | out-File "$path\backup_log.txt" 
 $attachment = "$destination\APTMKTDATA.cer" 

#>
 $messageParameters = @{                        
                Subject = "Test Email - $((Get-Date).ToShortDateString())"                        
                Body = "This is a test log created on: $date"                                
                From = "IITG Email Script Template <advtalk28@gmail.com>"                         
                To =    "Alvin Vaughn <alvin.vaughn@outlook.com>"                 
                SmtpServer = $smtp
                port = $smtpPort
                UseSsl = $true
                Credential = $credentials                      
            }                        
            Send-MailMessage @messageParameters -BodyAsHtml 

<# New example Template:
 $messageParameters = @{                        
                Subject = "Installed Program report for $env:ComputerName.$env:USERDNSDOMAIN - $((Get-Date).ToShortDateString())"                        
                Body = Get-WmiObject Win32_Product |                         
                    Select-Object Name, Version, Vendor |             
                    Sort-Object Name |             
                    ConvertTo-Html |                         
                    Out-String                        
                From = "Me@MyCompany.com"                        
                To = "Me@MyCompany.com"                        
                SmtpServer = "SmtpHost"                        
            }                        
            Send-MailMessage @messageParameters -BodyAsHtml       
#>