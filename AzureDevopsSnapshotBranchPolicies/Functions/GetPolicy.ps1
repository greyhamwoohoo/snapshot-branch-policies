<#
.SYNOPSIS
Gets a single instance of the given Policy or returns $null
#>
function GetPolicy {
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
        if($candidatePolicies.Count -gt 1) {
            throw "There are $($candidatePolicies.Count) policies for $PolicyFriendlyName, a ref of $refName and a repository Id of $($repository.Id). There should be 0 or 1)";
        }
        Write-Verbose "SUCCESS: There are $($candidatePolicies.Count) policies for $PolicyFriendlyName"

        $policy = $null;
        if($candidatePolicies.Count -eq 1) {
            $policy = $candidatePolicies[0];
        }

        return $policy;
    }
}
