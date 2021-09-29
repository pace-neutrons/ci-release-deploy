<#
.SYNOPSIS
  Handle operations to do with docs pushing
.DESCRIPTION
  Use "Get-Help Docs.ps1 -Detailed" for parameter descriptions.
.LINK
  https://github.com/pace-neutrons/ci-release-deploy
#>

param (
  # The action to perform valid options: 'push' or 'update-stable'
  [string]$Action=$(throw "Mandatory argument 'action' not specified."),
  # The desired name for the tag and release
  [string]$ReleaseName,
  # The token to provide authentication to GitHub
  [string]$AuthToken
)

# Pull latest gh-pages and set up for pushing
git config --local user.name "PACE CI Build Agent"
git config --local user.email "pace.builder.stfc@gmail.com"
git clone "https://github.com/pace-neutrons/Horace.git" --branch gh-pages --single-branch docs
cd docs
git remote set-url --push origin "https://pace-builder:$(${env:api_token}.trim())@github.com/pace-neutrons/Horace"

switch ($action) {
    'push' {

        # Overwrite old version if necessary
        git rm -rf --ignore-unmatch "./${ReleaseName}"
        New-Item -Path "./${ReleaseName}" -ItemType Directory

        Expand-Archive -Path ../docs.zip -DestinationPath "./${ReleaseName}"

        git add "./${ReleaseName}"
        git commit -m "Docs update for release ${ReleaseName}"

    }
    'update-stable' {

        # Set stable redirect
        Set-Content -Path ./stable/index.html -Value "<meta http-equiv=""Refresh"" content=""0; url='https://pace-neutrons.github.io/Horace/${ReleaseName}/'"" />"
        git add ./stable/index.html
        git commit -m "Stable update for release ${ReleaseName}"
    }
}

git push
