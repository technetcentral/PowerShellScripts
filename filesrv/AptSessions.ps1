function get-aptsessions() {
    
    Import-Module pslogging
    $logpath = “\\FILESRV\DomainShare\admins\logs\powerShellScripts\AptSurvDisconnect.log”
    Start-Log -LogPath “\\FILESRV\DomainShare\admins\logs\powerShellScripts\” -LogName “AptSurvDisconnect.log” -ScriptVersion “1.0” 

        Get-SmbOpenFile | where {$_.Path -like '*Apt*'} | Sort-Object  sessionid -Unique  |Foreach-Object {

            $session = $_
            $clients = Get-SmbSession | where {$_.ClientComputerName -eq $session.ClientComputerName} 

       
         New-Object -TypeName PSObject -Property @{
                SessionID = $clients.SessionId  
                User = $clients.ClientUserName
                Computer =  $clients.ClientComputerName
            } 

          $logDisconnects
          $logDisconnects = $clients.ClientUserName + ' on computer '+ $clients.ClientComputerName + ' disconnected.'
          Write-LogInfo -LogPath $logpath $logDisconnects
          #Close-SmbSession $clients.SessionId 

        }    |Format-Table -AutoSize  
       
      Write-LogInfo -LogPath $logpath -TimeStamp -ToScreen "Disconnect Task Completed"
      Stop-Log -LogPath $logpath  -NoExit

    } 
   

get-aptsessions
