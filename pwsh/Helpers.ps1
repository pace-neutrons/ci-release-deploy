<#
.SYNOPSIS
  This function is used to tag a commit and create a release on GitHub.
#>
function New-GitHubRelease {
  param(
    # An API token that provides authentication to GitHub
    [string]$AuthToken,
    # The SHA of the commit to create the tag and release on
    [string]$GitSHA,
    # The decscription of the release - usually release notes
    [string]$ReleaseBody,
    # The desired name for the release
    [string]$ReleaseName,
    # The name of the repository to create the release on
    [string]$RepoName,
    # The owner (username/organisation) of the repository to create the release on
    [string]$RepoOwner,
    # The name to give the created tag
    [string]$TagName,
    # Mark this release as a Draft release - do not publish it
    [bool]$Draft,
    # Mark this release as a pre-release
    [bool]$PreRelease
  )

  $releases_url = "https://api.github.com/repos/$RepoOwner/$RepoName/releases"
  $payload = @{
    tag_name = "$TagName"
    target_commitish = "$GitSHA"
    name = "$ReleaseName"
    body = "$ReleaseBody"
    draft = $Draft
    prerelease = $PreRelease
  }

  try {
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    $result = `
      Invoke-RestMethod `
        -URI $releases_url `
        -Headers @{Authorization = "token $AuthToken"} `
        -Method 'POST' `
        -ContentType "application/json" `
        -Body ($payload | ConvertTo-Json)
    return $result
  } catch {
    $_.Exception.Response
    $_.ErrorDetails.Message
    exit 1
  }
}

<#
.SYNOPSIS
  This function is used to upload a file (asset) to a GitHub release.
#>
function Publish-ReleaseAsset() {
  param(
    # The name to give the file/asset on GitHub
    [string]$AssetName,
    # The path to the file to be uploaded
    [string]$AssetPath,
    # The type of file that is being uploaded (e.g. zip)
    [string]$AssetType,
    # An API token that provides authentication to GitHub
    [string]$AuthToken,
    # The ID number of the release to publish the asset to
    [string]$ReleaseID,
    # The name of the repository to create the release on
    [string]$RepoName,
    # The owner (username/organisation) of the repository to create the release on
    [string]$RepoOwner
  )

  $upload_url = "https://uploads.github.com/repos/{0}/{1}/releases/{2}/assets"
  $upload_url = $upload_url -f @("$RepoOwner", "$RepoName", "$ReleaseID")
  $full_upload_url = "${upload_url}?name=${AssetName}"

  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
  try {
    $result = Invoke-RestMethod `
                -URI "$full_upload_url" `
                -Headers @{Authorization = "token $AuthToken"} `
                -Method 'POST' `
                -ContentType "application/$AssetType" `
                -InFile "$AssetPath"
  } catch {
    $_.Exception
    $_.ErrorDetails.Message
    exit 1
  }
  return $result
}

<#
.SYNOPSIS
  Function to deduce the content type of the given file. Only .zip and .tar.gz
  files are currently supported.
#>
function Get-ApplicationType() {
  param( [string]$FilePath )

  switch((Get-ChildItem $FilePath).Extension) {
    ".zip" { return "zip" }
    ".gz" { return "gzip" }
    default {
      Write-Error "Invalid extension type. Extension must be .zip or .gz.
                   Found '$((Get-ChildItem $FilePath).Extension)'"
      exit 2
    }
  }
}

<#
.SYNOPSIS
  Function to test whether the given release file names are releases that
  correspond to the given version number.
#>
function Test-VersionNumbers() {
  param( [string]$VersionNumber, [string[]]$ReleaseFileNames )

  foreach ($release in $ReleaseFileName) {
    $match = $ReleaseFireleaseleName -Match "-([0-9]+\.[0-9]+\.[0-9]+)-"
    if (!$match) {
      Write-Error "Could not locate version string in release name: $release."
      exit 1
    }

    $found_version = $Matches.1
    if ($found_version -ne $VersionNumber) {
      Write-Error("Given version number does not match found version " +
                  "number.`nFound '$found_version' in $ReleaseFileName, " +
                  "required version is '$VersionNumber'.")
      exit 1
    }
  }
}
