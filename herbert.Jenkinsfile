#!groovy

def repo_owner = "pace-neutrons"
def repo_name = "Herbert"

def release_id_description = (
  "The IDs of the jobs that contain the target release artifacts.\n" +
  "This parameter should have the form:\n\n" +
  "  <JOB_NAME> <BUILD_NUMBER>\n" +
  "  <JOB_NAME> <BUILD_NUMBER>\n" +
  "  ...")

def get_agent() {
  def agent_label = ''
  withCredentials([string(credentialsId: 'win10_agent', variable: 'agent')]) {
    agent_label = "${agent}"
  }
  return agent_label
}

properties([
  parameters([
    string(
      defaultValue: '',
      description: 'The SHA of the commit to create the tag/release on.',
      name: 'tag_sha',
      trim: true
    ),
    string(
      defaultValue: '',
      description: 'The version of this release (e.g. 3.4.1)',
      name: 'version_number',
      trim: true
    ),
    text(
      defaultValue: '',
      description: release_id_description,
      name: 'release_job_ids'
    ),
    text(
      defaultValue: '',
      description: 'The description of this release to show on GitHub e.g. release notes',
      name: 'release_body'
    ),
    booleanParam(
      defaultValue: false,
      description: 'Tick if this release should be marked as a pre-release on GitHub.',
      name: 'is_prerelease'
    ),
    booleanParam(
      defaultValue: false,
      description: 'Tick if this release should be marked as a draft on GitHub.',
      name: 'is_draft'
    )
  ])
])


pipeline {
  agent { label get_agent() }

  stages {
    stage('Get-Artifacts') {
      steps {
        script {
          List lines = env.release_job_ids.split('\n')
          for (String line : lines) {
            List build = line.split(' ')
            String project_name = build[0]
            String build_num = build[1]

            echo "Copying artifact from build #${build_num} of ${project_name}"
            copyArtifacts(
              filter: 'Herbert-*',
              fingerprintArtifacts: true,
              projectName: "${project_name}",
              selector: specific("${build_num}")
              target: '.'
            )
          }
        }
      }
    }

    stage('Push-Release') {
      steps {
        withCredentials([string(credentialsId: 'GitHub_API_Token',
                                variable: 'api_token')]) {
          powershell """
            \$artifacts = (Get-ChildItem -Filter ${repo_name}-*).Name
            foreach (\$artifact in \$artifacts) {
              \$artifact -Match "-([0-9]+\\.[0-9]+\\.[0-9]+)-"
              \$version_str = \$Matches.0

              if (\$version_str -ne ${version_number}) {
                Write-Error ("The 'version_number' parameter does not match " + `
                            "the version in the copied artifact.`n" +
                            "Found ${version_number} & \$version_str.")
                exit 1
              }
            }

            ./pwsh/Deploy-ToGitHub \
              -AssetPaths \$artifacts \
              -AuthToken ${api_token} \
              -GitSHA ${tag_sha} \
              -ReleaseBody "${release_body}" \
              -ReleaseName "v${version_number}" \
              -RepoName ${repo_name} \
              -RepoOwner ${repo_owner}
          """
        }
      }
    }

    stage('Validate-Release') {
      steps {
        // Validate that the tags are on GitHub along with the assets
        echo 'Validate-Release'
      }
    }
  }
}
