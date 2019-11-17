. $PSScriptRoot\GetPolicy.ps1

<#
.SYNOPSIS
Get the Minimum Number of Reviewers Policy. This policy will exist either 0 or 1 times. 

.DESCRIPTION
This is represented in the user interface as 'Require a minimum number of reviewers'.

This will always return a Policy object. The 'Enabled' property will be $false if the Policy is not Enabled.

.PARAMETER ProjectName
Team Project Name

.PARAMETER RepositoryId
The ID of the Repository

.PARAMETER RefName
The branch to query. ie: refs/heads/master. This is case sensitive. 
#>
function GetMinimumNumberOfReviewersPolicy {

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
        $policy = GetPolicy -RefName $RefName -ProjectName $ProjectName -RepositoryId $RepositoryId -PolicyId "fa4e907d-c16b-4a4c-9dfa-4906e5d171dd" -PolicyFriendlyName "MinimumReviewersPolicy"

        $returnValue = New-Object System.Management.Automation.PSObject

        if($null -ne $policy) {
            $returnValue | Add-Member -MemberType NoteProperty -Name "AllowDownvotes" -Value $policy.settings.allowDownVotes
            $returnValue | Add-Member -MemberType NoteProperty -Name "CreatorViewCounts" -Value $policy.settings.creatorVoteCounts
            $returnValue | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $policy.isEnabled
            $returnValue | Add-Member -MemberType NoteProperty -Name "MinimumApproverCount" -Value $policy.settings.minimumApproverCount
            $returnValue | Add-Member -MemberType NoteProperty -Name "ResetOnSourcePush" -Value $policy.settings.resetOnSourcePush
        } else {
            $returnValue | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $false
        }

        ($returnValue.Keys).ForEach{ Write-Verbose "$($_)=$($returnValue[$_])"}

        return $returnValue;
    }
}
