'''
'''
'''		Check and enforce the compliance of the local administrators group
'''
'''		By Jon Callahan - jon.callahan@microsoft.com
'''
'''
'''

Dim strComputer 
Dim colGroups
Dim objGroup 
Dim objUser
Dim strDeviceOwner, strDeviceOwnerDomain, strDeviceOwnerIsAdmin
Dim strUserName, strUserAdsPath
Dim EnforceCompliance
Dim strResult
Dim strLocalAdministratorsResult

Set objShell = CreateObject("WScript.Shell")

' Set log file path
	
sLogFileName = objShell.ExpandEnvironmentStrings("%WINDIR%") &"\CCM\logs\LocalAdministrators.log"

call WriteLogFileLine(sLogFileName, "BEGIN LocalAdministrators")

' Set and log EnforceCompliance mode

'EnforceCompliance = TRUE
EnforceCompliance = FALSE

If EnforceCompliance = TRUE Then
				
	call WriteLogFileLine(sLogFileName, "EnforceCompliance = TRUE - will enforce compliance")
	
Else
	
	call WriteLogFileLine(sLogFileName, "EnforceCompliance = FALSE - will not enforce compliance")
	
End If
	  
' Get Azure AD device ownership information

strDeviceOwner = GetAADDeviceOwner(strResult)
strDeviceOwnerDomain = GetAADDeviceOwnerDomain(strResult)
call WriteLogFileLine(sLogFileName, "Device owner is " & strDeviceOwnerDomain & "\" & strDeviceOwner)

' Enumerate local Administrators group membership

call WriteLogFileLine(sLogFileName, "Enumerating local Administrators group membership")
	  
strComputer = "."
Set colGroups = GetObject("WinNT://" & strComputer & "")
colGroups.Filter = Array("group")

For Each objGroup in colGroups
  
	If objGroup.Name = "Administrators" Then
	
		For Each objUser in objGroup.Members
			
			' Gather local Administrators group membership compliance and remove users if  EnforceCompliance = TRUE 
			
			If objUser.Name = "Administrator" or InStr(1, objUser.Name, "S-1-12-1") = 1 Then
					
				' Default administrator and Azure AD accounts
					
				call WriteLogFileLine(sLogFileName, objUser.Name & " is a default member of the local administrators group. Skipping...")

			ElseIf  objUser.Name = strDeviceOwner AND SetDeviceOwernIsAdmin(strResult) = 1 Then
				
				' Device owner is allowed in local administrators group 
				
				call WriteLogFileLine(sLogFileName, objUser.Name & " is allowed to be in the local administrator group.")
				
				strDeviceOwnerIsAdmin = TRUE
							
			Else
			
				' User account is not allowed in local administrators group 
						
				call WriteLogFileLine(sLogFileName, "ERROR " & objUser.Name & " is not allowed to be in the local administrators group.")
				 
				' Remove account from local administrators group 
				
				If EnforceCompliance = TRUE Then
				
					call WriteLogFileLine(sLogFileName, objUser.Name & " removed from local administrators")
					objGroup.Remove(objUser.ADsPath)
				
				Else
				
					strLocalAdministratorsResult = "Non-Compliant"
				
				End If
			
			End If
			
		Next
		
		' Add device owner to local administrators group if missing
		
		If strDeviceOwnerIsAdmin <> TRUE and SetDeviceOwernIsAdmin(strResult) = 1 and EnforceCompliance = TRUE Then
		
			objGroup.Add("WinNT://" & strDeviceOwnerDomain & "/" & strDeviceOwner)
			call WriteLogFileLine(sLogFileName, strDeviceOwner & " added to local administrators")
		
		End If
		
	End If
				
Next

' Set compliance state result

If strLocalAdministratorsResult = "Non-Compliant" Then
	
		call WriteLogFileLine(sLogFileName, "ERROR local administrators group membership is " & strLocalAdministratorsResult)
		
Else
	
	strLocalAdministratorsResult = "Compliant"
	call WriteLogFileLine(sLogFileName, "Local administrators group membership is " & strLocalAdministratorsResult)
	
End If

Wscript.Echo strLocalAdministratorsResult

call WriteLogFileLine(sLogFileName, "END LocalAdministrators")

' Determine if the device owner can be in the local administrators group

Function SetDeviceOwernIsAdmin(strResult)

	On Error Resume Next

	Dim bDeviceOwnerIsAdmin
	
	bDeviceOwnerIsAdmin = objShell.RegRead("HKLM\SOFTWARE\Microsoft\DeviceOwner\AllowDeviceOwnerLocalAdministrator")
	
	If Err.Number <> 0 Then
		Err.Clear
		bDeviceOwnerIsAdmin = 0
	End If
	
	SetDeviceOwernIsAdmin = bDeviceOwnerIsAdmin

End Function

' Determine  the Azure AD device owner

Function GetAADDeviceOwner(strResult)

	On Error Resume Next

	Dim objUserName
	objUserName = objShell.RegRead("HKLM\SOFTWARE\Microsoft\DeviceOwner\UserName")
	GetAADDeviceOwner = objUserName
	
	If Err.Number <> 0 Then
		Err.Clear
		GetAADDeviceOwner = "UNKNOWN"
	End If

End Function

' Determine the Azure AD device owner domain

Function GetAADDeviceOwnerDomain(strResult)

	On Error Resume Next

	Dim objUserEmail
	objUserDomain = objShell.RegRead("HKLM\SOFTWARE\Microsoft\DeviceOwner\UserDomain")
	GetAADDeviceOwnerDomain = objUserDomain
	
	If Err.Number <> 0 Then
		Err.Clear
		GetAADDeviceOwnerDomain = "UNKNOWN"
	End If

End Function

' Script logging

Function WriteLogFileLine(sLogFileName,sLogFileLine)
 
    dateStamp = Now()
    Set objFsoLog = CreateObject("Scripting.FileSystemObject") 
    Set logOutput = objFsoLog.OpenTextFile(sLogFileName, 8, True)
    logOutput.WriteLine(cstr(dateStamp) + " -" + vbTab + sLogFileLine) 
    logOutput.Close
    Set logOutput = Nothing 
    Set objFsoLog = Nothing
	
End Function
