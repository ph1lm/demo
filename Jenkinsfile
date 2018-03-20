pipeline {
  agent {
      label 'maven'
  }
  stages {
    stage('Build App') {
      steps {
        sh "mvn clean install"
      }
    }
    stage('Create Image Builder') {
      when {
        expression {
          openshift.withCluster() {
            return !openshift.selector("bc", "demo-binary").exists();
          }
        }
      }
      steps {
        script {
          openshift.withCluster() {
            openshift.newBuild("--name=demo-binary", "--image-stream=demo", "--binary")
          }
        }
      }
    }
    stage('Build Image') {
      steps {
        script {
          openshift.withCluster() {
            openshift.selector("bc", "demo-binary").startBuild("--from-file=target/demo-0.0.1-SNAPSHOT.jar", "--wait")
          }
        }
      }
    }
    stage('Promote to DEV') {
      steps {
        script {
          timeout(time: 1, unit: 'MINUTES') {
            input 'Promote to DEV?'
          }
          openshift.withCluster() {
            openshift.tag("demo:latest", "demo:dev")
          }
        }
      }
    }
    stage('Create DEV') {
      steps {
        script {
          openshift.withCluster() {
            openshift.newApp("demo:dev", "--name=demo-dev").narrow('svc').expose()
          }
        }
      }
    }
    stage('Promote STAGE') {
      steps {
        script {
          timeout(time: 1, unit: 'MINUTES') {
            input 'Promote to DEV?'
          }
          openshift.withCluster() {
            openshift.tag("demo:dev", "demo:stage")
          }
        }
      }
    }
    stage('Create STAGE') {
      steps {
        script {
          openshift.withCluster() {
            openshift.newApp("demo:stage", "--name=demo-stage").narrow('svc').expose()
          }
        }
      }
    }
  }
}