

$filepath = '\\FILESRV\DomainShare\admins\scripts\filesrvsmtpcs.txt'
Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File -FilePath $filepath