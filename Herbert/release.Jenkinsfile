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

def base_job_name = "${JOB_BASE_NAME}".trim().replace("Release-", "")

// Run the Branch-* pipeline to generate release
def handle = build(
  job: "Branch-${base_job_name}",
  parameters: [
    [
      $class: 'StringParameterValue',
      name: 'BRANCH_NAME',
      value: "$BRANCH_NAME",
    ],
    [
      $class: 'StringParameterValue',
      name: 'RELEASE_TYPE',
      value: "Release",
    ]
  ],
  propagate: true
)
