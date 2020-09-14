<#
.SYNOPSIS
  This script is used to tag a commit and create a release on GitHub.

.DESCRIPTION
  Use "Get-Help deploy_helpers.ps1 -Detailed" for parameter descriptions.

.LINK
  https://github.com/pace-neutrons/Herbert
#>
function create_release_tag {
  param(
    # An API token that provides authentication to GitHub
    [string]$auth_token,
    # The SHA of the commit to create the tag and release on
    [string]$git_sha,
    # The decscription of the release - usually release notes
    [string]$release_body,
    # The desired name for the release
    [string]$release_name,
    # The name of the repository to create the release on
    [string]$repo_name,
    # The owner (username/organisation) of the repository to create the release on
    [string]$repo_owner,
    # The name to give the created tag
    [string]$tag_name,
    # Mark this release as a draft release - do not publish it
    [switch]$draft,
    # Mark this release as a pre-release
    [switch]$prerelease
  )

  $releases_url = "https://api.github.com/repos/$repo_owner/$repo_name/releases"
  $payload = @{
    tag_name = "$tag_name";
    target_commitish = "$git_sha";
    name = "$release_name";
    body = "$release_body";
    draft = $false;
    prerelease = $false
  }

  try {
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    $result = `
      Invoke-RestMethod `
        -URI $releases_url `
        -Headers @{Authorization = "token $auth_token"} `
        -Method 'POST' `
        -ContentType "application/json" `
        -Body ($payload | ConvertTo-Json)
    return $result
  } catch {
    $_.Exception
    exit 1
  }
}

<#
.SYNOPSIS
  This script is used to upload a file (asset) to a GitHub release.

.DESCRIPTION
  Use "Get-Help deploy_helpers.ps1 -Detailed" for parameter descriptions.

.LINK
  https://github.com/pace-neutrons/Herbert
#>
function upload_release_asset() {
  param(
    # The path to the file to be uploaded
    [string]$asset_path,
    # The type of file that is being uploaded (e.g. zip)
    [string]$asset_type,
    # An API token that provides authentication to GitHub
    [string]$auth_token,
    # The release ID number
    [string]$release_id,
    # The name to give the file/asset on GitHub
    [string]$asset_name,
    # The name of the repository to create the release on
    [string]$repo_name,
    # The owner (username/organisation) of the repository to create the release on
    [string]$repo_owner
  )

  $upload_url = "https://uploads.github.com/repos/{0}/{1}/releases/{2}/assets"
  $upload_url = $upload_url -f @("$repo_owner", "$repo_name", "$release_id")
  $full_upload_url = "${upload_url}?name=${asset_name}"
  $full_upload_url

  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
  try {
    $result = Invoke-RestMethod `
                -URI "$full_upload_url" `
                -Headers @{Authorization = "token $auth_token"} `
                -Method 'POST' `
                -ContentType "application/$asset_type" `
                -InFile "$asset_path"
  } catch {
    $_.Exception
    exit 1
  }
  return $result
}
