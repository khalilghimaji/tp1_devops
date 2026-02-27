// ─────────────────────────────────────────────────────────────────
// Jenkinsfile — Pipeline Déclaratif CI/CD
// Projet : Visit-Counter (Flask + Redis + Docker)
// ─────────────────────────────────────────────────────────────────

pipeline {

  agent any

  environment {
    IMAGE_NAME            = "khalilghimaji/mon-app-devops"
    IMAGE_TAG             = "${BUILD_NUMBER}"
    DOCKER_CREDENTIALS_ID = "docker-hub-credentials"
  }

  stages {

    stage('Checkout') {
      steps {
        echo "==> Recuperation du code source..."
        checkout scm
        sh 'echo "Commit: $(git rev-parse --short HEAD)"'
      }
    }

    stage('Unit Tests') {
      steps {
        echo "==> Execution des tests unitaires..."
        sh '''
          docker run --rm \
            -v $(pwd):/app \
            -w /app \
            python:3.12-alpine \
            sh -c "pip install -q flask redis pytest && pytest test_app.py -v"
        '''
      }
      post {
        failure {
          error("ECHEC tests - pipeline interrompu, pas de push Docker.")
        }
      }
    }

    stage('Docker Build') {
      steps {
        echo "==> Construction de l'image Docker..."
        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
        sh "docker images ${IMAGE_NAME}"
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
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
          sh "docker push ${IMAGE_NAME}:latest"
          sh 'docker logout'
        }
        echo "==> Image publiee : ${IMAGE_NAME}:${IMAGE_TAG}"
      }
    }
  }

  post {
    success {
      echo "Pipeline reussi ! Image disponible sur Docker Hub."
      sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
      sh "docker rmi ${IMAGE_NAME}:latest || true"
    }
    failure {
      echo "Pipeline echoue. Consultez les logs ci-dessus."
    }
    always {
      sh 'docker image prune -f || true'
    }
  }
}