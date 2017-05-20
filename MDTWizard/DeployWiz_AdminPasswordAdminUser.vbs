' // ***************************************************************************
' // 
' // Copyright (c) Microsoft Corporation.  All rights reserved.
' // 
' // Microsoft Deployment Toolkit Solution Accelerator
' //
' // File:      DeployWiz_AdminPasswordAdminUser.vbs
' // 
' // Version:   1.0
' // 
' // Purpose:   Main Client Deployment Wizard Validation routines
' // Author:   Jon Callahan (jocallah@microsoft.com)
' // 
' // ***************************************************************************

Option Explicit


'''''''''''''''''''''''''''''''''''''
'  Validate Password
'

Function InitializeCreateNewAdminAccount

	If Property("CreateNewAdminAccount") = "YES" Then
	
		CreateNewAdminAccountRadio1.Checked = true
		NewAdminAccountPane.style.display = ""
	
	Else
	
		CreateNewAdminAccountRadio2.Checked = true
		NewAdminAcountName.disabled = TRUE
		NewAdminAccountPane.style.display = "none"
	
	End IF

End Function

Function ValidatePassword

	ValidatePassword = ParseAllWarningLabels

	NonMatchPassword.style.display = "none"
	If Password1.Value <> "" then
		If Password1.Value <> Password2.Value then
			ValidatePassword = FALSE
			NonMatchPassword.style.display = "inline"
		End if
	End if

	ButtonNext.Disabled = not ValidatePassword

End Function

Function ValidateNewAdminAccount

	If CreateNewAdminAccountRadio1.checked = TRUE Then
	
		NewAdminAcountName.disabled = FALSE
		NewAdminAccountPane.style.display = ""
	
	Else
	
		NewAdminAcountName.disabled = TRUE
		NewAdminAccountPane.style.display = "none"
		
		ValidatePassword
	
	End IF

End Function
