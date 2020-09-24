<#
.SYNOPSIS
  Function to test whether the given release file names are releases that
  correspond to the given version number.
.DESCRIPTION
  Use "Get-Help Test-VersionNumbers.ps1 -Detailed" for parameter descriptions.
.LINK
  https://github.com/pace-neutrons/ci-release-deploy
#>
param(
  # The version number that should be matched to the release file name
  [string]$VersionNumber=$(throw "Mandatory argument 'VersionNumber' not specified."),
  # The file names of the releases
  [string[]]$ReleaseFileNames=$(throw "Mandatory argument 'ReleaseFileNames' not specified.")
)

$VERSION_NUMBER_REGEX = "-([0-9]+\.[0-9]+\.[0-9]+)-"

foreach ($release in $ReleaseFileName) {
  $match = $ReleaseFireleaseleName -Match $VERSION_NUMBER_REGEX
  if (!$match) {
    Throw "Could not locate version string in release name: $release."
  }

  $found_version = $Matches.1
  if ($found_version -ne $VersionNumber) {
    Throw("Given version number does not match found version number.`n" +
          "Found '$found_version' in $ReleaseFileName, required version " +
          "is '$VersionNumber'.")
  } else {
    Write-Output "Found version matching '$VersionNumber' in $ReleaseFileName."
  }
}
