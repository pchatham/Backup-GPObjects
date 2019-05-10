<#
	.SYNOPSIS
		Backs up all Group Policy Objects linked to an OU, Sub-OUs or for the whole domain
		Creating a named folder for each GPO, for easier analysis and importing.
	
	.DESCRIPTION
		===========================================================================
		Created on:   	06/02/2019
		Created by:   	Phil Chatham
		Organization: 	
		Filename:     	Backup-GPObjects.ps1
		===========================================================================
	
	.PARAMETER OrganisationlUnit
		Name of Organisational Unit to backup (distinguishedName)
	
	.PARAMETER Output
		Path to output folder. Defaults to ENV:TEMP
	
	.PARAMETER Recurse
		Backs up all GPOs including sub-Organisational Units
	
	.PARAMETER Domain
		Backs up all GPO's in the current Domain
	
	.PARAMETER ShowOutput
		Opens output folder after backup process completes
	
	.PARAMETER Force
		Overwrites existing output folder without prompting
	
	.EXAMPLE
		PS C:\> .\Backup-GPObjects.ps1 -OU "OU=Computers,DC=LAB,DC=Internal" -ShowOutput
	
	.EXAMPLE
		PS C:\> .\Backup-GPObjects.ps1 -OU "OU=Computers,DC=LAB,DC=Internal" -Output 'C:\GPOBackup\2019' -Recurse
	
	.EXAMPLE
		PS C:\> .\Backup-GPObjects.ps1 -Domain -Output 'C:\Temp\GPOBackup\Domain'
	
	.EXAMPLE
		PS C:\> .\Backup-GPObjects.ps1 -Domain -Force -Verbose
	
	.NOTES
		Adapted from https://deploymentpros.wordpress.com/2018/01/23/powershell-backup-all-gpos-linked-to-an-ou/
#>
#Requires -Module ActiveDirectory
#Requires -Module GroupPolicy
param
(
	[Parameter(ParameterSetName = 'OU',
			   Mandatory = $false)]
	[Alias('OU')]
	[string]$OrganisationlUnit,
	[Parameter(ParameterSetName = 'Domain',
			   Mandatory = $false)]
	[Parameter(ParameterSetName = 'OU')]
	[string]$Output = "$ENV:TEMP\GPOBackup",
	[Parameter(ParameterSetName = 'OU',
			   Mandatory = $false)]
	[Alias('R')]
	[switch]$Recurse,
	[Parameter(ParameterSetName = 'Domain',
			   Mandatory = $false)]
	[Alias('D')]
	[switch]$Domain,
	[Parameter(ParameterSetName = 'Domain')]
	[Parameter(ParameterSetName = 'OU')]
	[Alias('SO')]
	[switch]$ShowOutput,
	[Parameter(ParameterSetName = 'OU')]
	[Parameter(ParameterSetName = 'Domain')]
	[Alias('F')]
	[switch]$Force
)

#region Test Backup Folder
If ((Test-Path $Output) -and (!($Force))) {
	
	# if Output folder exists
	Write-Warning "Backup Folder already exists"
	Write-Warning "Overwrite [$Output] ?"
	
	$Overwrite = Read-Host " ( Y / N ) "
	Switch ($Overwrite) {
		
		Y {
			Remove-Item -Path $Output -Recurse -Force
		}
		
		N {
			Write-Output 'Exiting...'
			break # breaks out of switch only
		}
		
		Default {
			Write-Output 'No Selection Exiting...'
			$Overwrite = 'N'
			Break # breaks out of switch only
		}
	}
}

if ($Overwrite -eq 'N') {
	Break # breaks out of function
}
#endregion 

#region Switch -  Force
if ($Force) {
	Remove-Item -Path $Output -Recurse -Force -ErrorAction SilentlyContinue
}
#endregion

# create output folder
Write-Verbose "Creating $Output Folder"
$null = New-Item -Path $Output -ItemType Directory | Out-Null

#region Switch - Domain
if ($Domain) {
	Write-Verbose "Domain Switch specified"
	$OrganisationlUnit = (Get-ADDomain $ENV:USERDOMAIN).DistinguishedName
	Write-Verbose "Domain : [$OrganisationlUnit]"
	$Recurse = $true
	Write-Verbose "Recurse triggered by -Domain switch"
}
#endregion

#region Switch - Recurse
if ($Recurse) {
	Write-Verbose "Collecting Group Policy Objects"
	$GPOs = (Get-ADOrganizationalUnit -SearchBase $OrganisationlUnit -Filter *).LinkedGroupPolicyObjects
	Write-Verbose "GPO Count : $($GPOs.Count)"
} else {
	# No Recurse specified
	Write-Verbose "Collecting Group Policy Objects"
	$GPOs = (Get-ADOrganizationalUnit -Identity $OrganisationlUnit).LinkedGroupPolicyObjects
	Write-Verbose "GPO Count $($GPOs.Count)"
}
#endregion

Write-Verbose "Backing up GPOs to $Output"

#region Backup routine
foreach ($GPO in $GPOs) {
	
	# Get GPO details
	$GPOGUID = "{" + ($GPO.Split("{")[1]).Split("}")[0] + "}"
	$GPOName = (Get-GPO -Guid $GPOGUID).DisplayName
	
	# Create backup folder and backup GPO
	Write-Output "Backing up GPO : $GPOName"
	Try {
		$null = New-Item -Path $Output\$GPOName -ItemType Directory -ErrorAction Stop | Out-Null
		$null = Backup-GPO -Guid $GPOGUID -Path $Output\$GPOName -ErrorAction Stop | Out-Null
	} Catch {
		Write-Warning "Duplicate : [$GPOName] : GPO may be Linked to multiple OUs"
	}
}
#endregion

if ($ShowOutput) {
	Start-Process $Output
}