' // ***************************************************************************
' // 
' // Copyright (c) Microsoft Corporation.  All rights reserved.
' // 
' // Microsoft Deployment Toolkit Solution Accelerator
' //
' // File:      DeployWiz_WindowsUpdate.vbs
' // 
' // Version:   1.0
' // 
' // Author:	Jon Callahan (jon.callahan@microsoft.com)
' // 
' // Purpose:   Windows Update wizard pane for MDT
' // 
' // ***************************************************************************


Option Explicit


Function InitializeWindowsUpdate

	If Property("ApplyWindowsUpdate") = "YES" Then
			
		If Property("WSUSServer") <> "" Then
	
			WSUSServer.Value = Property("WSUSServer")
			WSUSTargetGroup.Value = Property("TargetGroup")
			
			WindowsUpdateRadio2.Checked = true
		
		Else
	
			WindowsUpdateRadio1.Checked = true
			
		End If
					
	Else
	
		WindowsUpdateRadio3.Checked = true
	
	End If
	
	ValidateWindowsUpdate

End Function

Function ValidateWindowsUpdate

	If WindowsUpdateRadio2.Checked = true Then
	
		WSUSServerURL.disabled = FALSE
		
		If WSUSServerURL.value = "" Then
			
			ButtonNext.disabled = TRUE
		
		End If
		
	Else
	
		WSUSServerURL.disabled = TRUE
		
		ButtonNext.disabled = FALSE
		
	End If
	
	ValidateWindowsUpdate = TRUE

End Function

Function ValidateWindowsUpdateExit

	If WindowsUpdateRadio2.Checked = false Then
	
		WSUSServer.Value = ""
		
	End If
	
	ValidateWindowsUpdateExit = TRUE

End Function