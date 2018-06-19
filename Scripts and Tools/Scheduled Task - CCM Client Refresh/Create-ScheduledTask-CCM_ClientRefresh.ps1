$xmlContentsP1 = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <URI>\New CCM Client Refresh 5min</URI>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
      <Repetition>
        <Interval>PT5M</Interval>
        <Duration>PT1H</Duration>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>

'@

$xmlContentsP2 = @'

      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>PowerShell.exe</Command>
      <Arguments>-EncodedCommand JABzAGMAaABlAGQAPQAoAFsAdwBtAGkAXQAiAHIAbwBvAHQAXABjAGMAbQBcAFAAbwBsAGkAYwB5AFwATQBhAGMAaABpAG4AZQBcAEEAYwB0AHUAYQBsAEMAbwBuAGYAaQBnADoAQwBDAE0AXwBTAGMAaABlAGQAdQBsAGUAcgBfAFMAYwBoAGUAZAB1AGwAZQBkAE0AZQBzAHMAYQBnAGUALgBTAGMAaABlAGQAdQBsAGUAZABNAGUAcwBzAGEAZwBlAEkARAA9ACcAewAwADAAMAAwADAAMAAwADAALQAwADAAMAAwAC0AMAAwADAAMAAtADAAMAAwADAALQAwADAAMAAwADAAMAAwADAAMAAwADIAMQB9ACcAIgApADsAIABpAGYAIAAoACQAcwBjAGgAZQBkAC4AVAByAGkAZwBnAGUAcgBzACAALQBuAGUAIAAnAFMAaQBtAHAAbABlAEkAbgB0AGUAcgB2AGEAbAA7AE0AaQBuAHUAdABlAHMAPQA1ADsATQBhAHgAUgBhAG4AZABvAG0ARABlAGwAYQB5AE0AaQBuAHUAdABlAHMAPQA1ACcAKQB7ACAAJABzAGMAaABlAGQALgBUAHIAaQBnAGcAZQByAHMAPQBAACgAJwBTAGkAbQBwAGwAZQBJAG4AdABlAHIAdgBhAGwAOwBNAGkAbgB1AHQAZQBzAD0ANQA7AE0AYQB4AFIAYQBuAGQAbwBtAEQAZQBsAGEAeQBNAGkAbgB1AHQAZQBzAD0AMAAnACkAOwAgACQAcwBjAGgAZQBkAC4AUAB1AHQAKAApAH0A</Arguments>
    </Exec>
  </Actions>
</Task>
'@

$StartBoundary = "<StartBoundary>" + (Get-Date -Format s) + "</StartBoundary>"

$xmlContents = $xmlContentsP1 + $StartBoundary.ToString() + $xmlContentsP2

$xmlContents

Register-ScheduledTask -Xml $xmlContents -TaskName "New CCM Client Refresh 5min" -Force
Start-ScheduledTask -TaskName "New CCM Client Refresh 5min"