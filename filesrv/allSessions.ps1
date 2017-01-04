function get-allSessions() {
    
    Import-Module pslogging
    $logpath = “\\FILESRV\DomainShare\admins\logs\powerShellScripts\AllSessionDisconnect.log”
    Start-Log -LogPath “\\FILESRV\DomainShare\admins\logs\powerShellScripts\logs” -LogName “AllSessionDisconnect.log” -ScriptVersion “1.0” 

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

    } 

get-allSessions