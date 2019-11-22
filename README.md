[![Build Status](https://greyhamwoohoo.visualstudio.com/PowerShell-Modules/_apis/build/status/SnapshotBranchPolicies-Release?branchName=master)](https://greyhamwoohoo.visualstudio.com/PowerShell-Modules/_build/latest?definitionId=15&branchName=master)

# azure-devops-snapshot-branch-policies
Identify Configuration Drift of your Azure DevOps Branch Policies (Git Repositories only).

This module will let you snapshot and source control a 'Golden' copy of your Branch Policies in YAML. For example:

```
ProjectName: bootstrapping
RefName: refs/heads/master
RepositoryName: bootstrapping
AutomaticReviewersPolicies:
- Blocking: true
  CreatorVoteCounts: false
  Enabled: true
  FilenamePatterns:
  - c:\temp*
  - yeha.woo
  Message: theFeedMessage
  RequiredReviewerStorageKeyIds:
  - 11111111-20a0-41d6-9be5-eb913aca77b6
  - 11111112-1423-4dc2-8d35-84f1bac1417d
```

By taking a new snapshot and comparing it with the 'Golden' copy, you can identify drift. 

All Policies on the Branch Policies page are supported:

![Branch Policies](docs/policies-png.png?raw=true "Snapshot Branch Policies")

## Workflow
The workflow is straight forward:

1. Snapshot the 'Golden' state of your Branch Policies for a given Project, Repository and Branch ("Ref") and save. 
2. Snapshot the current state of your Branch Policies and save.
3. Compare :)

### Requirements
PowerShell 5.0+. Runs on PowerShell Core. 

## Quick Start
You are required to install the following modules first:

```
Install-Module vsteam
Install-Module powershell-yaml
Install-Module AzureDevopsSnapshotBranchPolicies
```

This module is little more than a wrapper around 'VsTeam' so you must configure VsTeam as follows:

```
Set-VSTeamAccount -Account YOURVSTSACCOUNT -PersonalAccessToken YOURPAT
```

To get your Personal Access Token, please see https://YOURACCOUNT.visualstudio.com/_usersSettings/tokens. To get up and running, create a new Token with Full Access. See Least Privelege below for the least privelege token you need. 

## Establish Golden Snapshot
To establish the 'golden' snapshot - the baseline that should not drift - set up your Branch Policies as you normally would in Azure DevOps.

To snapshot the state, three parameters are required:

1. ProjectName is the Team Project Name under your account. 
2. RepositoryName is the Repository Name under that Team Project. If there is only one repository, this will likely be the same as the ProjectName.
3. RefName is the Ref (Git Branch) whose policies are to be read. ie: refs/heads/master is the master branch.

```
$VerbosePreference="Continue"
$ErrorPreference="Stop"
Get-BranchPolicy -RefName "refs/heads/master" -ProjectName "YOURTEAMPROJECTNAME" -RepositoryName "YOURGITREPOSITORYNAME" | ConvertTo-Yaml  | Out-File -Force -Path "Golden.yaml"
```

This will produce Yaml output like this:

```
ProjectName: bootstrapping
RefName: refs/heads/master
RepositoryName: bootstrapping
AutomaticReviewersPolicies:
- Blocking: true
  CreatorVoteCounts: false
  Enabled: true
  FilenamePatterns:
  - c:\temp*
  - yeha.woo
  Message: theFeedMessage
  RequiredReviewerStorageKeyIds:
  - 11111111-20a0-41d6-9be5-eb913aca77b6
  - 11111112-1423-4dc2-8d35-84f1bac1417d
```

Persist that file as your golden.yaml definition. 

## Establish current Snapshot and compare
Take a snapshot of the current state:

``` 
Get-BranchPolicy -RefName "refs/heads/master" -ProjectName "YOURTEAMPROJECTNAME" -RepositoryName "YOURGITREPOSITORYNAME" | ConvertTo-Yaml | Out-File -Force -Path "Current.yaml"
```

Then just compare the two snapshots using whatever mechanism you prefer. In PowerShell, just compare the text files crudely with this (see Compare-Object for more information)

```
$original = "Golden.yaml"
$current = "Current.yaml"
Compare-Object -ReferenceObject $(Get-Content $original) -DifferenceObject $(Get-Content $current)
```

## Local Development
For local development, it makes sense to import the module directly. The setup is the same as above:

```
Install-Module vsteam
Set-VSTeamAccount -Account YOURVSTSACCOUNT -PersonalAccessToken YOURPAT

Install-Module powershell-yaml
Import-Module .\AzureDevopsSnapshotBranchPolicies\AzureDevopsSnapshotBranchPolicies.psd1 -Force
```

## Least Privelege
To set up a PAT with least privelege, you require the following settings:

| Claim | UI Setting |
| ----- | ---------- |
| vso.code | Scopes: Custom Defined, Code: Read |


# References
| Description | Link | 
| ----------- | ---- |
| Awesome YAML Support for Powershell | https://github.com/cloudbase/powershell-yaml |
| VsTeam - PowerShell Module for interacting with VsTs APIs | https://github.com/DarqueWarrior/vsteam |
