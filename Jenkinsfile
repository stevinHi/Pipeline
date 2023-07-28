pipeline {
  agent any
  stages {
    stage('Initialize') {
      steps {
        sh '''
          echo "PATH = ${PATH}"
          echo "M2_HOME = ${M2_HOME}"
        '''
      }
    }

    stage('Source Composition Analysis') {
      steps {
        sh 'rm owasp* || true'
        sh 'wget "https://raw.githubusercontent.com/RetireJS/retire.js/master/repository/jsrepository.json"'
        sh 'docker run --rm -v "$PWD:/report" owasp/dependency-check --scan /report --format "XML" --out /report/dependency-check-report.xml'
        sh 'cat dependency-check-report.xml'
      }
    }

    stage('SAST') {
      steps {
        withSonarQubeEnv('SonarqubeScan') {
          sh 'mvn SonarqubeScan:SonarqubeScan'
          sh 'cat target/SonarqubeScan/report-task.txt'
        }
      }
    }

    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Deploy-To-Docker') {
      steps {
        script {
          docker.withRegistry('https://your-docker-registry.com', 'docker-credentials-id') {
            def image = docker.build('your-app-image', './path/to/Dockerfile')
            image.push()
            sh 'docker run -d --name your-app-container -p 8080:80 your-app-image'
          }
        }
      }
    }

    stage('DAST') {
      steps {
        sshagent(['zap']) {
          sh 'ssh -o StrictHostKeyChecking=no ubuntu@13.232.158.44 "docker run -t owasp/zap2docker-stable zap-baseline.py -t http://13.232.202.25:8080/webapp/" || true'
        }
      }
    }
  }
}
