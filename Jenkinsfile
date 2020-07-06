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
            //we need some extra packages installing
            sh 'apk -Uuv add make groff less python py-pip'
//we need the AWS command line tools
            sh 'pip install awscli'
