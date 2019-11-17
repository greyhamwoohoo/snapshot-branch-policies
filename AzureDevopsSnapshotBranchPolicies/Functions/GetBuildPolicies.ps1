. $PSScriptRoot\GetPolicies.ps1

<#
.SYNOPSIS
Get the Build Validation Policy. This policy will exist either 0, 1 or many times.  

.DESCRIPTION
This is represented in the user interface as 'Build validation'.

This will always return an array of 0, 1 or more Policy Objects

.PARAMETER ProjectName
Team Project Name

.PARAMETER RepositoryId
The ID of the Repository

.PARAMETER RefName
The branch to query. ie: refs/heads/master. This is case sensitive. 
#>
function GetBuildPolicies {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProjectName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RefName
    )
    PROCESS
    {
        $policies = @(GetPolicies -RefName $RefName -ProjectName $ProjectName -RepositoryId $RepositoryId -PolicyId "0609b952-1397-4640-95ec-e00a01b2c241" -PolicyFriendlyName "BuildPolicies")

        $returnValue = @()

        ($policies).ForEach{ 

            $filenamePatterns = $_.settings.FilenamePatterns;
            if($null -eq $filenamePatterns) {
                $filenamePatterns = @();
            }

            $candidatePolicy = New-Object System.Management.Automation.PSObject
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "Blocking" -Value $_.isBlocking
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "BuildDefinitionId" -Value $_.settings.buildDefinitionId
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $_.settings.DisplayName
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $_.isEnabled
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "FilenamePatterns" -Value @($filenamePatterns | Sort-Object)
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "ManualQueueOnly" -Value $_.settings.manualQueueOnly
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "QueueOnSourceUpdateOnly" -Value $_.settings.queueOnSourceUpdateOnly
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "ValidDuration" -Value $_.settings.validDuration

            $returnValue += $candidatePolicy;
        }

        # The magic , will ensure that an array of one element is not 'unrolled' into an object: we will always get back an array this way
        return ,$returnValue;
    }
}