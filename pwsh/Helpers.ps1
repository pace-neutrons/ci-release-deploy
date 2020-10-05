$ALLOWED_ASSET_EXTENSIONS = @{
  ".zip" = "zip"
  ".gz" = "gzip"
}
$BASE_RELEASES_URL = "https://{0}.github.com/repos/{1}/{2}/releases"

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

  $releases_url = $BASE_RELEASES_URL -f @("api", $RepoOwner, $RepoName)
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

  $upload_url = $BASE_RELEASES_URL -f @("uploads", "$RepoOwner", "$RepoName")
  $full_upload_url = "${upload_url}/${ReleaseID}/assets?name=${AssetName}"

  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
  try {
    Write-Output "Uploading asset $AssetPath to $full_upload_url..."
    Invoke-RestMethod `
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
}

<#
.SYNOPSIS
  Function to deduce the MIME application type of the given file. Only .zip and
  .gz files are currently supported.
#>
function Get-MimeApplicationType() {
  param( [string]$FilePath )

  if (Test-FileExtension $FilePath) {
    return $ALLOWED_ASSET_EXTENSIONS.((Get-ChildItem $FilePath).Extension)
  } else {
    Throw("File '$FilePath' has invalid file extension.`n" + `
          "Allowed extensions are: $($ALLOWED_ASSET_EXTENSIONS.keys)")
  }
}

<#
.SYNOPSIS
  Validate the given file's against the allowed file extensions defined at the
  top of this file.
#>
function Test-FileExtension() {
  param( [string[]]$FilePath )

  $extension = (Get-ChildItem $FilePath).Extension
  return $ALLOWED_ASSET_EXTENSIONS.ContainsKey("$extension")
}

