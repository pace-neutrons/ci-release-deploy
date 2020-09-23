<#
.SYNOPSIS
  Find files matching the given filter and compare their contents with the
  given SHA. Throw an error if the SHA differs from any of the found files
  contents.
.DESCRIPTION
  Use "Get-Help Test-GitShaFiles.ps1 -Detailed" for parameter descriptions.
.LINK
  https://github.com/pace-neutrons/ci-release-deploy
#>
param (
  # The required Git SHA to match to the discovered files
  [string]$RequiredSHA=$(throw "Mandatory argument 'RequiredSHA' not specified."),
  # The filter to use to discover SHA files (this is passed to Get-ChildItem)
  [string]$Filefilter=$(throw "Mandatory argument 'FileFilter' not specified.")
)

$sha_files = (Get-ChildItem -Filter "$FileFilter").Name
if ($sha_files.Length -eq 0) {
  Throw "No files found matching filter '$FileFilter'."
}

$err_encountered = $false
foreach ($sha_file in $sha_files) {
  $sha = (Get-Content $sha_file).trim()

  if ($sha -ne $RequiredSHA) {
    $err_encountered = $true
    Write-Error("SHA '$sha' in file $sha_file does not match required SHA " +
                "'$RequiredSHA'`n")
  }
}

if ($err_encountered) {
  exit 1
}
