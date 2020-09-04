#!groovy

// Set this pipeline's properties
properties([
  [
    $class: 'GithubProjectProperty',
    displayName: '',
    projectUrlStr: 'https://github.com/pace-neutrons/Herbert/'
  ],
  parameters([
    string(
      defaultValue: '',
      description: 'The branch to create a release from.',
      name: 'BRANCH_NAME',
      trim: true
    )
  ])
])


def run_build(String pipeline_name) {
  def handle = build(
    job: "${pipeline_name}",
    parameters: [
      [
        $class: 'StringParameterValue',
        name: 'BRANCH_NAME',
        value: "${BRANCH_NAME}",
      ],
      [
        $class: 'StringParameterValue',
        name: 'RELEASE_TYPE',
        value: "Release",
      ]
    ],
    propagate: true
  )
}

pipeline {
  agent any

  stages {

    stage('Run-builds') {

      matrix {
        axes {
            axis {
                name 'PLATFORM'
                values 'Scientific-Linux-7', 'Windows-10'
            }
            axis {
                name 'MATLAB_RELEASE'
                values '2018b', '2019b'
            }
        }
        stages {
          stage('Trigger-Branch') {
            steps {
              run_build("Branch-${PLATFORM}-${MATLAB_RELEASE}")
            }
          }
        }
      }
    }
  }
}
