pipeline {
  agent {
    label 'maven'
  }
  stages {

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
            openshift.newBuild('--name=demo-binary', '--image-stream=redhat-openjdk18-openshift:latest', '--binary')
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
          input 'Deploy to DEV?'
          openshift.withCluster() {
            openshift.tag('demo-binary:latest', 'demo-dev:latest')
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
            openshift.newApp('demo-dev:latest', '--name=demo-dev').narrow('svc')
          }
        }
      }
    }

    stage('Promote QA') {
      steps {
        script {
          input 'Promote to QA?'
          openshift.withCluster() {
            openshift.tag('demo-dev:latest', 'demo-qa:latest')
          }
        }
      }
    }
    stage('Create QA') {
      when {
        expression {
          openshift.withCluster() {
            return !openshift.selector('dc', 'demo-qa').exists()
          }
        }
      }
      steps {
        script {
          openshift.withCluster() {
            openshift.newApp('demo-qa:latest', '--name=demo-qa').narrow('svc')
          }
        }
      }
    }

    stage('Promote PROD') {
      steps {
        script {
          input 'Promote to PROD?'
          openshift.withCluster() {
            openshift.tag('demo-qa:latest', 'demo-prod:latest')
          }
        }
      }
    }
    stage('Create PROD') {
      when {
        expression {
          openshift.withCluster() {
            return !openshift.selector('dc', 'demo-prod').exists()
          }
        }
      }
      steps {
        script {
          openshift.withCluster() {
            openshift.newApp('demo-prod:latest', '--name=demo-prod').narrow('svc')
          }
        }
      }
    }
  }
}
