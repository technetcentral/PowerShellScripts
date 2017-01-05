

$filepath = '\\FILESRV\DomainShare\admins\scripts\smtpcs.txt'
Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File -FilePath $filepath