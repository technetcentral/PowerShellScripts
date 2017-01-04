
#System Variable for backup Procedure 
 
 $date = Get-Date -Format d-MMMM-yyyy 
 
 # $destination = '\\vfs04\Users$\vaugha1\Documents'
  
#Email Variables 
 
 $smtp = "smtp.gmail.com"
 $smtpPort = "587" 
 $from = "IITG Script Email <advtalk28@gmail.com>" 
 $to = "Alvin Vaughn <alvin.vaughn@harrishealth.org>" 
 $body = "Test Log: $date" 
 $subject = "Test Log Capture Email on $date" 
  
# Backup Process started  
            #$backup_log = Dir -Recurse $destination | out-File "$destination\backup_log.txt" 
  #          $attachment = "$destination\APTMKTDATA.cer" 
   # -Attachments $attachment

#Send an Email to User  
  send-MailMessage -SmtpServer $smtp -port $smtpPort -UseSsl -From $from -To $to -Credential (Get-credential) -Subject $subject  -Body $body -BodyAsHtml  
 