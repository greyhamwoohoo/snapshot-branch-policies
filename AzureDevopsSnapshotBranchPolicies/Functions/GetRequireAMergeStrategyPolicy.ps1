. $PSScriptRoot\GetPolicy.ps1

<#
.SYNOPSIS
Get the Requires A Merge Strategy Policy. This policy will exist either 0 or 1 times. 

.DESCRIPTION
This is represented in the user interface as 'Limit merge types'.

This will always return a Policy object. The 'Enabled' property will be $false if the Policy is not Enabled.

.PARAMETER ProjectName
Team Project Name

.PARAMETER RepositoryId
The ID of the Repository

.PARAMETER RefName
The branch to query. ie: refs/heads/master. This is case sensitive. 
#>
function GetRequireAMergeStrategyPolicy {

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
        $policy = GetPolicy -RefName $RefName -ProjectName $ProjectName -RepositoryId $RepositoryId -PolicyId "fa4e907d-c16b-4a4c-9dfa-4916e5d171ab" -PolicyFriendlyName "RequireAMergeStrategyPolicy"

        $returnValue = New-Object System.Management.Automation.PSObject

        if($null -ne $policy) {
            $returnValue | Add-Member -MemberType NoteProperty -Name "AllowNoFastForward" -Value ([Boolean] $policy.settings.allowNoFastForward)
            $returnValue | Add-Member -MemberType NoteProperty -Name "AllowRebase" -Value ([Boolean] $policy.settings.allowRebase)
            $returnValue | Add-Member -MemberType NoteProperty -Name "AllowRebaseMerge" -Value ([Boolean] $policy.settings.allowRebaseMerge)
            $returnValue | Add-Member -MemberType NoteProperty -Name "AllowSquash" -Value ([Boolean] $policy.settings.allowSquash)
            $returnValue | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $policy.isEnabled
        } else {
            $returnValue | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $false
        }

        Write-Verbose $returnValue

        return $returnValue;
    }
}