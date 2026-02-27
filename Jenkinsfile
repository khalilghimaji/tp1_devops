pipeline {

  agent any

  environment {
    IMAGE_NAME            = "khalil_ghimaji/mon-app-devops"
    IMAGE_TAG             = "${BUILD_NUMBER}"
    DOCKER_CREDENTIALS_ID = "docker-hub-credentials"
  }

  stages {

    stage('Checkout') {
      steps {
        echo "==> Recuperation du code source..."
        checkout scm
        bat 'git rev-parse --short HEAD'
      }
    }

    stage('Unit Tests') {
      steps {
        echo "==> Execution des tests unitaires..."
        bat '''
        docker run --rm ^
          -v %cd%:/app ^
          -w /app ^
          python:3.12-alpine ^
          sh -c "pip install -q flask redis pytest && pytest test_app.py -v"
        '''
      }
    }

    stage('Docker Build') {
      steps {
        echo "==> Construction de l'image Docker..."
        bat "docker build -t %IMAGE_NAME%:%IMAGE_TAG% -t %IMAGE_NAME%:latest ."
        bat "docker images %IMAGE_NAME%"
      }
    }

    stage('Docker Push') {
      steps {
        echo "==> Publication sur Docker Hub..."
        withCredentials([usernamePassword(
          credentialsId: "${DOCKER_CREDENTIALS_ID}",
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {

          bat "echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin"
          bat "docker push %IMAGE_NAME%:%IMAGE_TAG%"
          bat "docker push %IMAGE_NAME%:latest"
          bat "docker logout"
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline reussi !"
      bat "docker rmi %IMAGE_NAME%:%IMAGE_TAG% || exit 0"
      bat "docker rmi %IMAGE_NAME%:latest || exit 0"
    }
    always {
      bat "docker image prune -f || exit 0"
    }
  }
}