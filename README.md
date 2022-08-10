# Backup-GPObjects
Powershell script to Backup Group Policy Objects for a Domain or Specific OU
Backs up all Group Policy Objects linked to an OU, Sub-OUs or for the whole domain, Creating a named folder for each GPO, for easier analysis and importing.

# Requirements
- Powershell v4
- Powershell Module - ActiveDirectory
- Powershell Module - GroupPolicy

# Examples
- Backup OU and show output at the end
	- .\Backup-GPObjects.ps1 -OU "OU=Computers,DC=LAB,DC=Internal" -ShowOutput
	
- Backup OU, specify outpur directory and include sub-OUs
	- .\Backup-GPObjects.ps1 -OU "OU=Computers,DC=LAB,DC=Internal" -Output 'C:\GPOBackup\2019' -Recurse
 
- Backup all Domain GPOs and Specify output directory
	- .\Backup-GPObjects.ps1 -Domain -Output 'C:\Temp\GPOBackup\Domain'
 
- Backup all Domain GPOs, overwrite any exisiting backup with verbose output
	- .\Backup-GPObjects.ps1 -Domain -Force -Verbose
	
