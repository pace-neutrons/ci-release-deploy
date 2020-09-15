<#
.SYNOPSIS
  Create a release and push the given assets to that release.
.DESCRIPTION
  Use "Get-Help Deploy-ToGithub.ps1 -Detailed" for parameter descriptions.
.LINK
  https://github.com/pace-neutrons/ci-release-deploy
#>
param(
  # The path to files to be uploaded to release
  [string[]]$AssetPaths,
  # The token to provide authentication to GitHub
  [string]$AuthToken,
  # The SHA of the commit to create the tag and release on
  [string]$GitSHA,
  # The decscription of the release - usually release notes
  [string]$ReleaseBody,
  # The desired name for the tag and release
  [string]$ReleaseName,
  # The name of the repository to create the release on
  [string]$RepoName,
  # The owner (username/organisation) of the repository containing the release
  [string]$RepoOwner,
  # Mark this release as a Draft release - do not publish it
  [switch]$Draft,
  # Mark this release as a pre-release
  [switch]$PreRelease
)

<# Import:
  New-GitHubRelease
  Publish-ReleaseAsset
  Get-ApplicationType #>
. $PSScriptRoot\Helpers.ps1

foreach ($AssetPath in $AssetPaths) {
  if (!(Test-Path $AssetPath)) {
    Write-Error("Cannot upload asset. File '$AssetPath' does not exist.`n" +
                "Release not created.")
    exit 1
  }
}

$tag_opts = @{
  "AuthToken" = "$AuthToken"
  "Draft" = $Draft
  "GitSHA" = "$GitSHA"
  "PreRelease" = $PreRelease
  "ReleaseBody" = "$ReleaseBody"
  "ReleaseName" = "$ReleaseName"
  "RepoName" = "$RepoName"
  "RepoOwner" = "$RepoOwner"
  "TagName" = "$ReleaseName"
}

Write-Output "Creating release $ReleaseName on $GitSHA in $RepoOwner/$RepoName..."
$result = New-GitHubRelease @tag_opts
Write-Output "Release $ReleaseName created succesfully.`n"

foreach ($AssetPath in $AssetPaths) {

  $asset_opts = @{
    "AssetName" = (Get-ChildItem $AssetPath).Name
    "AssetPath" = "$AssetPath"
    "AssetType" = (Get-ApplicationType -FilePath $AssetPath)
    "AuthToken" = "$AuthToken"
    "ReleaseID" = $result.id
    "RepoName" = "$RepoName"
    "RepoOwner" = "$RepoOwner"
  }

  Write-Output "Uploading asset $AssetPath..."
  Publish-ReleaseAsset @asset_opts | Out-Null
  Write-Output "Asset $AssetPath uploaded.`n"
}
