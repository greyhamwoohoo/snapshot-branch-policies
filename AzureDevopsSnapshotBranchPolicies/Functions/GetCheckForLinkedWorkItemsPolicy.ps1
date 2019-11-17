. $PSScriptRoot\GetPolicy.ps1

<#
.SYNOPSIS
Get the Check For Linked Work Items Policy. This policy will exist either 0 or 1 times. 

.DESCRIPTION
This is represented in the user interface as 'Check for linked work items'.

This will always return a Policy object. The 'Enabled' property will be $false if the Policy is not Enabled.

.PARAMETER ProjectName
Team Project Name

.PARAMETER RepositoryId
The ID of the Repository

.PARAMETER RefName
The branch to query. ie: refs/heads/master. This is case sensitive. 
#>
function GetCheckForLinkedWorkItemsPolicy {

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
        $policy = GetPolicy -RefName $RefName -ProjectName $ProjectName -RepositoryId $RepositoryId -PolicyId "40e92b44-2fe1-4dd6-b3d8-74a9c21d0c6e" -PolicyFriendlyName "CheckForLinkedWorkItemsPolicy"

        $returnValue = New-Object System.Management.Automation.PSObject

        if($null -ne $policy) {
            $returnValue | Add-Member -MemberType NoteProperty -Name "Blocking" -Value $policy.isBlocking
            $returnValue | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $policy.isEnabled
        } else {
            $returnValue | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $false
        }

        ($returnValue.Keys).ForEach{ Write-Verbose "$($_)=$($returnValue[$_])"}

        return $returnValue;
    }
}