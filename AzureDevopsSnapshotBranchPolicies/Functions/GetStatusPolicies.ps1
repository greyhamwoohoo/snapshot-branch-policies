. $PSScriptRoot\GetPolicies.ps1

<#
.SYNOPSIS
Get the Require Approval from Additional Services Policy. This policy will exist either 0, 1 or many times.  

.DESCRIPTION
This is represented in the user interface as 'Require approval from additional services'.

This will always return an array of 0, 1 or more Policy Objects

.PARAMETER ProjectName
Team Project Name

.PARAMETER RepositoryId
The ID of the Repository

.PARAMETER RefName
The branch to query. ie: refs/heads/master. This is case sensitive. 
#>
function GetStatusPolicies {

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
        $policies = @(GetPolicies -RefName $RefName -ProjectName $ProjectName -RepositoryId $RepositoryId -PolicyId "cbdc66da-9728-4af8-aada-9a5a32e4a226" -PolicyFriendlyName "ApprovalFromAdditionalServices")

        $returnValue = @()

        ($policies).ForEach{ 

            $candidatePolicy = New-Object System.Management.Automation.PSObject

            $filenamePatterns = $_.settings.filenamePatterns;
            if($null -eq $filenamePatterns) {
                $filenamePatterns = @();
            }

            $policyApplicability = 0;
            if($null -ne $_.settings.policyApplicability) {
                $policyApplicability = $_.settings.policyApplicability;
            }

            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "AuthorId" -Value $_.settings.authorId

            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "Blocking" -Value $_.isBlocking
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "DefaultDisplayName" -Value $_.settings.defaultDisplayName
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $_.isEnabled
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "FilenamePatterns" -Value @($filenamePatterns | Sort-Object)
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "InvalidateOnSourceUpdate" -Value $_.settings.invalidateOnSourceUpdate
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "PolicyApplicability" -Value $policyApplicability
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "StatusGenre" -Value $_.settings.statusGenre
            $candidatePolicy | Add-Member -MemberType NoteProperty -Name "StatusName" -Value $_.settings.statusName

            $returnValue += $candidatePolicy;
        }

        # The magic , will ensure that an array of one element is not 'unrolled' into an object: we will always get back an array this way
        return ,$returnValue;
    }
}