#+-------------------------------------------------------------------+   
#| = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = |   
#|{>/-------------------------------------------------------------\<}|            
#|: | Author:  Aman Dhally                                        | :|            
#| :| Email:   amandhally@gmail.com 
#|: | Purpose: Smart Backup and create folder by Date        
#| :|           
#|: |                                                        
#| :|           
#|: |                 Date: 29 November 2011  
#|: |                             
#| :|     /^(o.o)^\    Version: 1                                    |: |  
#|{>\-------------------------------------------------------------/<}| 
#| = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = | 
#+-------------------------------------------------------------------+ 
 
 
#System Variable for backup Procedure 
 
 $date = Get-Date -Format d-MMMM-yyyy 
 
  
#Email Variables 
 
 $smtp = "smtp.gmail.com"
 $smtpPort = "587" 
 $from = "IITG Script Email <advtalk28@gmail.com>" 
 $to = "Alvin Vaughn <alvin.vaughn@outlook.com>" 
 $body = "Log File of N drive database bacupk is attached for: $date" 
 $subject = "Backup on $date" 
  
# Backup Process started  
            $backup_log = Dir -Recurse $destination | out-File "$destination\backup_log.txt" 
            $attachment = "$destination\backup_log.txt" 

#Send an Email to User  
  send-MailMessage -SmtpServer $smtp -port $smtpPort -UseSsl -From $from -To $to -Credential (Get-credential) -Subject $subject -Attachments $attachment -Body $body -BodyAsHtml  
 