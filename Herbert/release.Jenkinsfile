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
    ),
    choice(
      choices: ['all', 'Scientific-Linux-7', 'Windows-10'],
      description: 'Choose which platforms to run the builds on.',
      name: 'PLATFORM_FILTER'
    ),
    choice(
      choices: ['all', '2018b', '2019b'],
      description: 'Choose which Matlab release to run the builds with.',
      name: 'MATLAB_RELEASE_FILTER'
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
  agent none

  stages {

    stage('Run-builds') {
      matrix {
        // "when" block allows one to run the release pipeline for one or all
        // of the matrix configurations, depending on the values given in the
        // MATLAB_RELEASE_FILTER & PLATFORM_FILTER variables
        when { anyOf {
          expression {
            (params.PLATFORM_FILTER == 'all') && (
                params.MATLAB_RELEASE_FILTER == 'all')
          }
          expression {
            (params.PLATFORM_FILTER == 'all') && (
                params.MATLAB_RELEASE_FILTER == env.MATLAB_RELEASE)
          }
          expression {
            (params.PLATFORM_FILTER == env.PLATFORM) && (
                params.MATLAB_RELEASE_FILTER == 'all')
          }
          expression {
            (params.PLATFORM_FILTER == env.PLATFORM) && (
                params.MATLAB_RELEASE_FILTER == env.MATLAB_RELEASE)
          }
        }}

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
