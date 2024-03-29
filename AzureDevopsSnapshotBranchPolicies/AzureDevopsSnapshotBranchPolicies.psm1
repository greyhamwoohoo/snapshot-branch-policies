# AzureDevopsSnapshotBranchPolicies.psm1
# 
# Retrieves the Branch Policies for a given Git Branch in Azure DevOps
#
# To test with Pester:
# 1. Install-Module -Name Pester -Force -SkipPublisherCheck
# 2. Invoke-Pester
#
# To see Code Coverage:
# Invoke-Pester -CodeCoverageOutputFileFormat JaCoCo -CodeCoverage @(Get-ChildItem *.ps1 -Recurse | ?{ !$_.Name.Contains(".Tests.") })
# 
# Author: greyhamwoohoo

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. $here\Cmdlets\Get-BranchPolicy.ps1
Export-ModuleMember -Function "Get-BranchPolicy"

