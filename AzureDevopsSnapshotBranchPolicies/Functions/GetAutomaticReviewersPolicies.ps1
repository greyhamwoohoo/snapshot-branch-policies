
. $PSScriptRoot\GetPolicies.ps1

<#
.SYNOPSIS
Get the Required Reviewers Policy. This policy will exist either 0, 1 or many times.  

.DESCRIPTION
This is represented in the user interface as 'Automatically include code reviewers'.

This will always return an array of 0, 1 or more Policy Objects

.PARAMETER ProjectName
Team Project Name

.PARAMETER RepositoryId
The ID of the Repository

.PARAMETER RefName
The branch to query. ie: refs/heads/master. This is case sensitive. 
#>
function GetAutomaticReviewersPolicies {

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
        $policies = @(GetPolicies -RefName $RefName -ProjectName $ProjectName -RepositoryId $RepositoryId -PolicyId "fd2167ab-b0be-447a-8ec8-39368250530e" -PolicyFriendlyName "RequiredReviewers")

        $returnValue = @();

        #
        # To convert the ReviewerID into a Descriptor: Get-VSTeamDescriptor -StorageKey theId
        # To retrieve information about the Descriptior (email address etc): Get-VSTeamUser -Descriptor theDescriptorReturnedAbove
        #
        ($policies).ForEach{

            $candidatePolicy = New-Object System.Management.Automation.PSObject

            $filenamePatterns = $_.settings.filenamePatterns;
            if($null -eq $filenamePatterns) {
                $filenamePatterns = @();
            }

            $requiredReviewerIds = $_.settings.requiredReviewerIds
            if($null -eq $requiredReviewerIds) {
                $requiredReviewerIds = @()
            }

            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "Blocking" -Value $_.isBlocking
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "CreatorVoteCounts" -Value $_.settings.creatorVoteCounts
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $_.isEnabled
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "FilenamePatterns" -Value @($filenamePatterns | Sort-Object)
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "Message" -Value $_.settings.message
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "RequiredReviewerStorageKeyIds" -Value @($requiredReviewerIds | Sort-Object)

            $returnValue += $candidatePolicy
        }

        return ,$returnValue;
    }
}

