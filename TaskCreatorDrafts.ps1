

$Action = New-ScheduledTaskAction -Execute 'C:WindowsSystem32WindowsPowerShellv1.0powershell.exe' -Argument "-NonInteractive -NoLogo -NoProfile -File 'C:SomePowerShellscript.ps1'"

$Trigger = New-ScheduledTaskTrigger -Daily -At '3AM'

$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings (New-ScheduledTaskSettingsSet)

$Task | Register-ScheduledTask -TaskName ‘My PowerShell' script -User 'administrator' -Password 'supersecret'







###########################################################################################





$action = New-ScheduledTaskAction -Execute 'Powershell.exe' `

  -Argument '-NoProfile -WindowStyle Hidden -command "& {get-eventlog -logname Application -After ((get-date).AddDays(-1)) | Export-Csv -Path c:\fso\applog.csv -Force -NoTypeInformation}"'

$trigger =  New-ScheduledTaskTrigger -Daily -At 9am

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AppLog" -Description "Daily dump of Applog"







##########################################################################################################################################



$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NonInteractive -NoLogo -NoProfile -File '\\FILESRV\DomainShare\admins\scripts\GitHub\powershellscripts\morningUpdateMessage.ps1'"

$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Thursday -At 10:10pm

$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings (New-ScheduledTaskSettingsSet)

$Task | Register-ScheduledTask -TaskName ‘Weekly Update Message' script -User 'amd\amd.admin' -Password 'ABCcty99##' -Description "Weekly Update Message"






###########################################################################################





$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "'-NoProfile -WindowStyle Hidden -File '\\FILESRV\DomainShare\admins\scripts\GitHub\powershellscripts\morningUpdateMessage.ps1' "

$trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Thursday -At 10:10pm 

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Weekly MSG" -Description "Weekly Update Message"

#####################################################################################################################################################







$TaskAction = New-ScheduledTaskAction -Execute "$TaskCommand" -Argument "$TaskArg" 
$TaskTrigger = New-ScheduledTaskTrigger -At $TaskStartTime -Once
Register-ScheduledTask -Action $TaskAction -Trigger $Tasktrigger -TaskName "$TaskName" -User "System" -RunLevel Highest








##########################################################################################

$TaskName = "MyScheduledTask"
# The description of the task
$TaskDescr = "Run a powershell script through a scheduled task"
# The Task Action command
$TaskCommand = "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
# The PowerShell script to be executed
$TaskScript = "C:\scripts\myscript.ps1"
# The Task Action command argument
$TaskArg = "-WindowStyle Hidden -NonInteractive -Executionpolicy unrestricted -file $TaskScript"
 
# The time when the task starts, for demonstration purposes we run it 1 minute after we created the task
$TaskStartTime = [datetime]::Now.AddMinutes(1) 
 
# attach the Task Scheduler com object
$service = new-object -ComObject("Schedule.Service")
# connect to the local machine. 
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa381833(v=vs.85).aspx
$service.Connect()
$rootFolder = $service.GetFolder("\")
 
$TaskDefinition = $service.NewTask(0) 
$TaskDefinition.RegistrationInfo.Description = "$TaskDescr"
$TaskDefinition.Settings.Enabled = $true
$TaskDefinition.Settings.AllowDemandStart = $true
 
$triggers = $TaskDefinition.Triggers
#http://msdn.microsoft.com/en-us/library/windows/desktop/aa383915(v=vs.85).aspx
$trigger = $triggers.Create(1) # Creates a "One time" trigger
$trigger.StartBoundary = $TaskStartTime.ToString("yyyy-MM-dd'T'HH:mm:ss")
$trigger.Enabled = $true
 
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa381841(v=vs.85).aspx
$Action = $TaskDefinition.Actions.Create(0)
$action.Path = "$TaskCommand"
$action.Arguments = "$TaskArg"
 
#http://msdn.microsoft.com/en-us/library/windows/desktop/aa381365(v=vs.85).aspx
$rootFolder.RegisterTaskDefinition("$TaskName",$TaskDefinition,6,"System",$null,5)


$TaskAction = New-ScheduledTaskAction -Execute "$TaskCommand" -Argument "$TaskArg" 
$TaskTrigger = New-ScheduledTaskTrigger -At $TaskStartTime -Once
Register-ScheduledTask -Action $TaskAction -Trigger $Tasktrigger -TaskName "$TaskName" -User "System" -RunLevel Highest

#######################################################################################################################################