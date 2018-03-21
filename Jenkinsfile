pipeline {
  agent {
    label 'maven'
  }
  stages {
    stage('Build') {
      when {
        expression {
          openshift.withCluster() {
            return !openshift.selector('bc', 'demo-spring').exists();
          }
        }
      }
      steps {
        script {
          openshift.withCluster() {
            openshift.newApp('demo-spring:0.1~https://github.com/ph1lm/demo')
          }
        }
      }
    }
    stage('Build App') {
      steps {
        sh 'mvn clean install'
      }
    }
    stage('Create Image Builder') {
      when {
        expression {
          openshift.withCluster() {
            return !openshift.selector('bc', 'demo-binary').exists();
          }
        }
      }
      steps {
        script {
          openshift.withCluster() {
            openshift.newBuild('--name=demo-binary', '--image-stream=demo-spring', '--binary')
          }
        }
      }
    }
    stage('Build Image') {
      steps {
        script {
          openshift.withCluster() {
            openshift.selector('bc', 'demo-binary').startBuild('--from-file=target/demo-0.0.1-SNAPSHOT.jar', '--wait')
          }
        }
      }
    }
    stage('Promote to DEV') {
      steps {
        script {
          input 'Promote to DEV?'
          openshift.withCluster() {
            openshift.tag('demo:latest', 'demo:dev')
          }
        }
      }
    }
    stage('Create DEV') {
      when {
        expression {
          openshift.withCluster() {
            return !openshift.selector('dc', 'demo-dev').exists()
          }
        }
      }
      steps {
        script {
          openshift.withCluster() {
            openshift.newApp('demo:dev', '--name=demo-dev').narrow('svc')
          }
        }
      }
    }
    stage('Promote STAGE') {
      steps {
        script {
          input 'Promote to STAGE?'
          openshift.withCluster() {
            openshift.tag('demo:dev', 'demo:stage')
          }
        }
      }
    }
    stage('Create STAGE') {
      when {
        expression {
          openshift.withCluster() {
            return !openshift.selector('dc', 'demo-stage').exists()
          }
        }
      }
      steps {
        script {
          openshift.withCluster() {
            openshift.newApp('demo:stage', '--name=demo-stage').narrow('svc')
          }
        }
      }
    }
  }
}
