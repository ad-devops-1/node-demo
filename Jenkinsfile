def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger',
]
pipeline {
  agent none
  environment {
    //put your environment variables
    doError = '0'
    DOCKER_REPO = "878291833136.dkr.ecr.ap-south-1.amazonaws.com/node-demo"
    AWS_DEFAULT_REGION = "ap-south-1"
    HELM_RELEASE_NAME = "node-demo"
  }
    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
  }
//check every minute for changes
  triggers {
    pollSCM('*/1 * * * *')
  }
  stages {
    //Build container image
    stage('Build') {
      agent {
        kubernetes {
          label 'jenkinsrun'
          defaultContainer 'dind'
          yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: dind
    image: docker:18.05-dind
    securityContext:
      privileged: true
    volumeMounts:
      - name: dind-storage
        mountPath: /var/lib/docker
  volumes:
    - name: dind-storage
      emptyDir: {}
"""
        }
      }
      steps {
        container('dind') {
          script {
            sh 'apk -Uuv add make groff less python py-pip'
            sh 'pip install awscli'
          } //script
        } //container
      } //steps
}
    stage ('Build and Test') {
      steps {
        sh '''
        docker build --network=host \
        -t ${DOCKER_REPO}:${BUILD_NUMBER} .
        #put your Test cases
        echo 'Starting test cases'
        '''
      }
    }
    stage ('Artefact') {
      steps {
        sh '''
        apt update && apt install python-pip -y && pip install awscli && aws --version
        $(aws ecr get-login --region ap-south-1 --no-include-email)
        docker push ${DOCKER_REPO}:${BUILD_NUMBER}
        '''
        }
    }
    stage ('Deploy') {
      steps {
        sh '''
        CLUSTER_NAME=scikiq-non-prod
        aws eks --region $AWS_DEFAULT_REGION  update-kubeconfig --name ${CLUSTER_NAME}
        curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
        chmod +x ./kubectl
        mv ./kubectl /usr/local/bin/kubectl
        curl https://helm.baltorepo.com/organization/signing.asc | apt-key add -
        apt-get install apt-transport-https --yes
        echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
        apt-get update
        apt-get install helm -y
        helm upgrade --install node-demo node-demo --set image.repository=878291833136.dkr.ecr.ap-south-1.amazonaws.com/node-demo --set image.tag=${BUILD_NUMBER}
        '''
      }
    }
// slack notification configuration
  stage('Error') {
    // when doError is equal to 1, return an error
    when {
        expression { doError == '1' }
    }
    steps {
        echo "Failure :("
        error "Test failed on purpose, doError == str(1)"
    }
}
  stage('Success') {
    // when doError is equal to 0, just print a simple message
    when {
        expression { doError == '0' }
    }
    steps {
        echo "Success :)"
    }
}
  }
    // Post-build actions
  post {
      always {
          slackSend channel: '#test123',
              color: COLOR_MAP[currentBuild.currentResult],
              message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} More info at: https://jenkins.squareops.com/blue/organizations/jenkins/$JOB_BASE_NAME/detail/$JOB_BASE_NAME/$BUILD_NUMBER"
      }
  }
} //pipeline
