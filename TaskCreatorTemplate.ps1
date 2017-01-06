$TaskName = "MorningUpdateMSG"
# The description of the task
$TaskDescr = "Weekly Update Message"
# The Task Action command
$TaskCommand = "powershell.exe"
# The PowerShell script to be executed
$TaskScript = '\\FILESRV\DomainShare\admins\scripts\GitHub\powershellscripts\morningUpdateMessage.ps1'
# The Task Action command argument
$TaskArg = "-WindowStyle Hidden -NonInteractive -Executionpolicy unrestricted -file $TaskScript"

 
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

 
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa381841(v=vs.85).aspx
$Action = $TaskDefinition.Actions.Create(0)
$action.Path = "$TaskCommand"
$action.Arguments = "$TaskArg"
 

$TaskAction = New-ScheduledTaskAction -Execute "$TaskCommand" -Argument "$TaskArg" 
#$TaskTrigger = New-ScheduledTaskTrigger -At $TaskStartTime -Once
$trigger =  New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 09:00Am 
Register-ScheduledTask -Action $TaskAction -Trigger $trigger -TaskName "$TaskName" -User "amd\amd.admin" -Password "ABCcty99##" #-RunLevel Highest