# Backup-GPObjects
Powershell function to Backup Group Policy Objects for a Domain or Specific OU

# Requirements
- Powershell v4
- Powershell Module - ActiveDirectory
- Powershell Module - GroupPolicy

# Examples


- Backup OU and show output at the end
PS C:\> .\Backup-GPObjects.ps1 -OU "OU=Computers,DC=LAB,DC=Internal" -ShowOutput
	
- Backup OU, specify outpur directory and include sub-OUs
PS C:\> .\Backup-GPObjects.ps1 -OU "OU=Computers,DC=LAB,DC=Internal" -Output 'C:\GPOBackup\2019' -Recurse
 
- Backup all Domain GPOs and Specify output directory
PS C:\> .\Backup-GPObjects.ps1 -Domain -Output 'C:\Temp\GPOBackup\Domain'
 
- Backup all Domain GPOs, overwrite any exisiting backup with verbose output
PS C:\> .\Backup-GPObjects.ps1 -Domain -Force -Verbose
	
