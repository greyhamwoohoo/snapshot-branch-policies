<#
.SYNOPSIS
Returns an array of 0, 1 or more policies.
#>
function GetPolicies {
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
        $RefName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PolicyId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PolicyFriendlyName        
    )    
    PROCESS
    {
        # Use Get-VSTeamPolicyType -ProjectName $ProjectName to retrieve all of the different policy IDs available

        Write-Verbose "TRY: To get the $PolicyFriendlyName Policy"
        $candidatePolicies = (Get-VSTeamPolicy -ProjectName $ProjectName).Where{ $_.type.id -eq $PolicyId }.Where{ $_.settings.scope.refName -eq $refName }.Where{ $_.settings.scope.repositoryId -eq $RepositoryId }
Write-Verbose "SUCCESS: There are $($candidatePolicies.Count) policies for $PolicyFriendlyName"

        return $candidatePolicies;
    }
}