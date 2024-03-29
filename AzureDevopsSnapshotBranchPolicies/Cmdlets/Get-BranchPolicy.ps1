. ([System.IO.Path]::Combine((Get-Item $PSScriptRoot).Parent.FullName, "Functions", "GetMinimumNumberOfReviewersPolicy.ps1"))
. ([System.IO.Path]::Combine((Get-Item $PSScriptRoot).Parent.FullName, "Functions", "GetRequireAMergeStrategyPolicy.ps1"))
. ([System.IO.Path]::Combine((Get-Item $PSScriptRoot).Parent.FullName, "Functions", "GetCheckForLinkedWorkItemsPolicy.ps1"))
. ([System.IO.Path]::Combine((Get-Item $PSScriptRoot).Parent.FullName, "Functions", "GetCheckForCommentResolutionPolicy.ps1"))
. ([System.IO.Path]::Combine((Get-Item $PSScriptRoot).Parent.FullName, "Functions", "GetAutomaticReviewersPolicies.ps1"))
. ([System.IO.Path]::Combine((Get-Item $PSScriptRoot).Parent.FullName, "Functions", "GetBuildPolicies.ps1"))
. ([System.IO.Path]::Combine((Get-Item $PSScriptRoot).Parent.FullName, "Functions", "GetStatusPolicies.ps1"))

<#
.SYNOPSIS
Gets the Branch Policies for the given Team Project, RepositoryName and RefName (branch)

.DESCRIPTION
Fetches all of the policies that are found on the 'Policies' page of a given Azure DevOps Git Branch. 

This Module relies on VsTeam so you must call Set-VsTeamAccount. 

.PARAMETER ProjectName
Name of the Team Project. ie: bootstrapping

.PARAMETER RepositoryName
Name of the Repository. If your Team Project has only a single repository, this is usually the same as the ProjectName. 

.PARAMETER RefName
The branch/ref whose policies you wish to retrieve. ie: for master: refs/heads/master. 

.EXAMPLE
C:\PS> Set-VSTeamAccount -Account "YOURVSTSACCOUNT" -PersonalAccessToken "YOURPAT"
C:\PS> Get-BranchPolicy -ProjectName bootstrapping -RepositoryName vue-js -RefName "refs/heads/master"
Name                           Value
----                           -----
CheckForCommentResolutionPo... {Blocking, Enabled}
RequiredReviewersPolicy        {Policies}
ProjectName                    bootstrapping
RequireAMergeStrategyPolicy    {AllowRebase, AllowNoFastForward, AllowRebaseMerge, AllowSquash...}
MinimumReviewersPolicy         {ResetOnSourcePush, AllowDownvotes, CreatorViewCounts, MinimumApproverCount...}
StatusPolicy                   {Policies}
RepositoryName                 RepositoryName
CheckForLinkedWorkItemsPolicy  {Blocking, Enabled}
RefName                        refs/heads/master
BuildValidationPolicy          {Policies}
#>
function Get-BranchPolicy {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProjectName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RefName
    )
    PROCESS 
    {
        Write-Verbose "TRY: To retrieve all GitRepositories in the project called $projectName"
        $projectRepositories = (Get-VSTeamGitRepository).Where{ $_.Project.Name -eq $projectName }.ForEach{ $_ | Select-Object -Property Project,Name,Id }
        if($projectRepositories.Count -eq 0) {
        throw "There are no repositories in the project called '$projectName'. "
        }    
        Write-Verbose "SUCCESS: $($projectRepositories.Count) were retrieved for the project called $projectName";
        $projectRepositories.ForEach{ Write-Verbose $_ }

        Write-Verbose "TRY: To find a GitRepository called $RepositoryName";
        $candidateRepositories = ($projectRepositories).Where({ $_.Name -eq $RepositoryName })
        if($candidateRepositories.Count -ne 1) {
        throw "There are '$($candidateRepositories.Count)' repositories called '$RepositoryName' in the project called '$projectName'. There is expected to be exactly one. "
        }
        Write-Verbose "SUCCESS: A single repository called $RepositoryName was retrieved. ";
        
        $repository = $candidateRepositories | Select-Object -First 1

        Write-Verbose "TRY: To fetch all GitRefs in the repository called $RepositoryName with an id of $($repository.ID)"
        $allRefs = (Get-VSTeamGitRef -ProjectName $projectName -RepositoryID $repository.ID)
        $candidateRefs = $allRefs.Where{ $_.RefName -eq $refName }
        if($candidateRefs.Count -ne 1) {
        throw "There are '$($candidateRefs.Count)' refs were found matching the name '$refName' in the repository called '$RepositoryName' in the project called '$projectName'. There is expected to be exactly one. "
        }
        
        $ref = $candidateRefs[0]
        Write-Verbose "SUCCESS: GitRef found called $($ref.RefName). This is the REF we will be getting the policies for. "

        $minimumReviewersPolicy = GetMinimumNumberOfReviewersPolicy -ProjectName $ProjectName -RepositoryId $repository.Id -RefName $RefName
        $checkForLinkedWorkItemsPolicy = GetCheckForLinkedWorkItemsPolicy -ProjectName $ProjectName -RepositoryId $repository.Id -RefName $RefName
        $checkForCommentResolutionPolicy= GetCheckForCommentResolutionConfiguration -ProjectName $ProjectName -RepositoryId $repository.Id -RefName $RefName
        $requireMergeStrategyPolicy= GetRequireAMergeStrategyPolicy -ProjectName $ProjectName -RepositoryId $repository.Id -RefName $RefName

        $buildPolicies = GetBuildPolicies -ProjectName $ProjectName -RepositoryId $repository.Id -RefName $RefName
        $statusPolicies = GetStatusPolicies -ProjectName $ProjectName -RepositoryId $repository.Id -RefName $RefName
        $automaticReviewersPolicies = GetAutomaticReviewersPolicies -ProjectName $ProjectName -RepositoryId $repository.Id -RefName $RefName

        $returnValue = New-Object System.Management.Automation.PSObject
        $returnValue | Add-Member -MemberType NoteProperty -Name "ProjectName" -Value $ProjectName
        $returnValue | Add-Member -MemberType NoteProperty -Name "RefName" -Value $RefName
        $returnValue | Add-Member -MemberType NoteProperty -Name "RepositoryName" -Value $RepositoryName

        $returnValue | Add-Member -MemberType NoteProperty -Name "AutomaticReviewersPolicies" -Value $automaticReviewersPolicies
        $returnValue | Add-Member -MemberType NoteProperty -Name "BuildPolicies" -Value $buildPolicies
        $returnValue | Add-Member -MemberType NoteProperty -Name "CheckForCommentResolutionPolicy" -Value $checkForCommentResolutionPolicy
        $returnValue | Add-Member -MemberType NoteProperty -Name "CheckForLinkedWorkItemsPolicy" -Value $checkForLinkedWorkItemsPolicy
        $returnValue | Add-Member -MemberType NoteProperty -Name "MinimumReviewersPolicy" -Value $minimumReviewersPolicy
        $returnValue | Add-Member -MemberType NoteProperty -Name "RequireAMergeStrategyPolicy" -Value $requireMergeStrategyPolicy
        $returnValue | Add-Member -MemberType NoteProperty -Name "StatusPolicies" -Value $statusPolicies

        return $returnValue;
    }
}
