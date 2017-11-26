Set objShell = CreateObject("Wscript.Shell")
Set objShellEnv = objShell.Environment("Process")
currentDirectory = objShell.CurrentDirectory
computerName  = objShellEnv("ComputerName")
Set fso = CreateObject("Scripting.FileSystemObject")
Dim PSRun
PSRun = "powershell.exe -WindowStyle hidden -ExecutionPolicy bypass -NonInteractive -File .\Get-WindowsAutoPilotInfo.ps1 -OutputFile .\" & computerName & ".csv"""
objShell.Run(PSRun),0,TRUE

csvPath = currentDirectory & "\" & computerName & ".csv"

If (fso.FileExists(csvPath)) Then


	PSRun = "cmd.exe /c echo " & currentDirectory & "\" & computerName & ".csv has been created && pause"
	objShell.Run(PSRun),1

Else

	PSRun = "cmd.exe /c echo " & computerName & ".csv not created. Check that you are in the folder that contains Get-AutoPilotInfo.vbs && pause"
	objShell.Run(PSRun),1

End If