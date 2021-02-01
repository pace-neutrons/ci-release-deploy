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
      description: 'The version of this release (e.g. 3.4.1)',
      name: 'version_number',
      trim: true
    )
  ])
])

pipeline {
  agent { label get_agent() }

  stages {

    stage ('Update-Stable') {
      when {
        expression{env.update_stable.toBoolean()}
      }
      // Assuming windows
      steps {

        withCredentials([string(credentialsId: 'GitHub_API_Token',
                                variable: 'api_token')]) {
          powershell """
            ./pwsh/Docs -Action "update-stable" \
                        -ReleaseName ${version_number} \
                        -AuthToken \${env:api_token}
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
