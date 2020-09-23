#!groovy

def repo_owner = "pace-neutrons"
def release_id_description = (
  "The IDs of the jobs that contain the target release artifacts.\n" +
  "This parameter should have the form:\n\n" +
  "  <JOB_NAME>, <BUILD_NUMBER>;\n" +
  "  <JOB_NAME>, <BUILD_NUMBER>;\n" +
  "           ...\n" +
  "With a comma separating job name and build number and a semi-colon " +
  "separating entries, whitespace is ignored.")

def get_agent() {
  def agent_label = ''
  withCredentials([string(credentialsId: 'win10_agent', variable: 'agent')]) {
    agent_label = "${agent}"
  }
  return agent_label
}

def get_repo_name(String job_name) {
  if (job_name.contains('Herbert/')) {
    return 'Herbert'
  } else if (job_name.contains('Horace/')) {
    return 'Horace'
  }
  return ''
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
      description: 'The description of this release to show on GitHub e.g. release notes. This should be formatted as markdown.',
      name: 'release_body'
    ),
    booleanParam(
      defaultValue: true,
      description: 'Tick if this release should be marked as a draft on GitHub.',
      name: 'is_draft'
    ),
    booleanParam(
      defaultValue: false,
      description: 'Tick if this release should be marked as a pre-release on GitHub.',
      name: 'is_prerelease'
    ),
    string(
      defaultValue: get_repo_name(env.JOB_NAME),
      description: 'The name of the repository to create the release in.',
      name: 'repo_name'
    )
  ])
])


pipeline {
  agent { label get_agent() }

  stages {
    stage('Get-Artifacts') {
      steps {
        script {
          List lines = env.release_job_ids.split(';')
          for (String line : lines) {
            if (line.strip()) {
              List build = line.split(',')
              String project_name = build[0].strip()
              String build_num = build[1].strip()

              echo "Copying artifact from build #${build_num} of ${project_name}"
              copyArtifacts(
                filter: "**/${repo_name}-*,*git-revision*",
                fingerprintArtifacts: true,
                flatten: true,
                projectName: "${project_name}",
                selector: specific("${build_num}"),
                target: '.'
              )
            }
          }
        }
      }
    }

    stage('Validate-Packages') {
      steps {
        powershell """
          ./pwsh/Test-GitShaFiles \
              -RequiredSHA ${tag_sha} \
              -FileFilter \"*git-revision*\"

          \$artifacts = (Get-ChildItem -Filter ${repo_name}-*).Name
          ./pwsh/Test-VersionNumbers \
              -VersionNumber ${version_number} \
              -ReleaseFileNames \$artifacts
        """
      }
    }

    stage('Push-Release') {
      steps {
        withCredentials([string(credentialsId: 'GitHub_API_Token',
                                variable: 'api_token')]) {
          powershell """
            \$artifacts = (Get-ChildItem -Filter ${repo_name}-*).Name

            ./pwsh/Deploy-ToGitHub \
                -AssetPaths \$artifacts \
                -AuthToken ${api_token} \
                -GitSHA ${tag_sha} \
                -ReleaseBody "${release_body}" \
                -ReleaseName "v${version_number}" \
                -RepoName ${repo_name} \
                -RepoOwner ${repo_owner} \
                -Draft \$${is_draft} \
                -PreRelease \$${is_prerelease}
          """
        }
      }
    }
  }

  post {
    cleanup {
      deleteDir()
    }
  }
}
