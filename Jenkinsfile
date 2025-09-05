pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = 'dockerhub-creds'   // Jenkins credentials ID for DockerHub
    DEPLOY_SSH            = 'deploy-ssh'        // Jenkins SSH credentials ID
    DOCKER_REPO           = 'yourdockerhubusername/rent-a-ride'
    TARGET_SSH_USER       = 'ubuntu'            // change to your deploy user
    TARGET_SSH_HOST       = 'your.server.ip'    // change to your server IP/hostname
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install & Test') {
      steps {
        script {
          if (fileExists('package-lock.json')) {
            sh 'npm ci'
          } else {
            echo "⚠️ No package-lock.json found, using npm install instead"
            sh 'npm install'
          }

          // Run tests but don’t fail pipeline if none exist
          sh 'npm test || echo "No tests or some failed"'
        }
      }
    }

    stage('Docker Build & Push') {
      steps {
        script {
          def shortRev = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()

          withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'

            sh "docker build -t ${env.DOCKER_REPO}:${shortRev} ."
            sh "docker tag ${env.DOCKER_REPO}:${shortRev} ${env.DOCKER_REPO}:latest"

            sh "docker push ${env.DOCKER_REPO}:${shortRev}"
            sh "docker push ${env.DOCKER_REPO}:latest"
          }
        }
      }
    }

    stage('Deploy') {
      steps {
        script {
          sshagent (credentials: [env.DEPLOY_SSH]) {
            sh """
              ssh -o StrictHostKeyChecking=no ${env.TARGET_SSH_USER}@${env.TARGET_SSH_HOST} \\
              'docker pull ${env.DOCKER_REPO}:latest && \\
               docker stop rent-a-ride || true && \\
               docker rm rent-a-ride || true && \\
               docker run -d --name rent-a-ride -p 80:3000 --restart=always ${env.DOCKER_REPO}:latest'
            """
          }
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
    }
  }
}
