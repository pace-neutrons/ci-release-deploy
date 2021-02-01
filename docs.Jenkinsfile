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
            git config --local user.name "PACE CI Build Agent"
            git config --local user.email "pace.builder.stfc@gmail.com"
            git clone "https://github.com/pace-neutrons/Horace.git" --branch gh-pages --single-branch docs
            cd docs
            git remote set-url --push origin "https://pace-builder:\$(\${env:api_token}.trim())@github.com/pace-neutrons/Horace"

            Write-Host '<meta http-equiv="Refresh" content="0; url=''https://pace-neutrons.github.io/Horace/${version_number}/''" />'
            Set-Content -Path ./stable/index.html -Value '<meta http-equiv="Refresh" content="0; url=''https://pace-neutrons.github.io/Horace/${version_number}/''" />'
            git add ./stable/index.html
            git commit -m 'Stable update for release ${version_number}'
            git push
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
