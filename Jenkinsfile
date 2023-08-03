pipeline {
    agent any
    stages {
        stage('Initialize') {
            steps {
                sh 'rm -f cloc.xml'
                sh 'rm -f sloccount.sc'
                sh 'rm -f cpd.xml'    
                sh '''
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
                '''
            }
        }

        stage('Source Composition Analysis') {
            steps {
                sh 'sudo mkdir /report'
                sh 'sudo chown -R jenkins:jenkins /report'
                sh 'sudo chown -R jenkins:docker /report'
                // Analyse de composition des sources, détection de vulnérabilités, etc.
                sh 'rm owasp* || true'
                sh 'wget "https://raw.githubusercontent.com/RetireJS/retire.js/master/repository/jsrepository.json"'
                sh 'docker run --rm -v "$PWD:/report" owasp/dependency-check --scan /report --format "XML" --out /report/dependency-check-report.xml'
                // Ignorer les erreurs pour ne pas arrêter le pipeline en cas de vulnérabilités
                sh 'cat /report/dependency-check-report.xml || true'
            }
        }

        stage('SAST') {
            steps {
                // Analyse statique de sécurité du code
                withSonarQubeEnv('SonarqubeScan') {
                    // Exécuter l'analyse de sécurité sur une branche spécifique plutôt que sur master/main
                    sh 'mvn SonarqubeScan:SonarqubeScan -Dsonar.branch.name=$BRANCH_NAME'
                    // Ignorer les erreurs pour ne pas arrêter le pipeline en cas de problèmes
                    sh 'cat target/SonarqubeScan/report-task.txt || true'
                }
            }
        }

        stage('CSA - Container Security Analysis') {
            steps {
                // Analyse de sécurité des conteneurs avec HARBOR
                // Assurez-vous que votre registry HARBOR est accessible ici
                sh 'docker pull your-harbor-registry/your-app-image:$BRANCH_NAME || true'
                sh 'docker scan your-harbor-registry/your-app-image:$BRANCH_NAME'
            }
        }

        stage('Build Frontend') {
            steps {
                dir('MobileInvoice') {
                    sh 'npm install'
                    sh 'npm run build'
                }
            }
        }
        
        stage('Create Symbolic Link') {
            steps {
                sh 'rm phing || true'
                sh 'ln -s ./MobileInvoice/vendor/bin/phing phing'
            }
        }
        
        stage('Full Build with Phing') {
            steps {
                sh './phing -buildfile /var/lib/jenkins/jobs/OrangeMoney-MobileInvoice-Test/workspace/MobileInvoice/build.xml full-build'
            }
        }

        stage('RASP - Runtime Application Self-Protection') {
            steps {
                // Mise en place de RASP pour protéger l'application en temps d'exécution
                // Assurez-vous d'installer le RASP sur le serveur d'exécution ici
                sh 'crowdsec enable your-app || true'
            }
        }

        stage('Deploy to Remote Server') {
            steps {
                sh 'ssh-keyscan -t rsa,dsa 213.32.14.59 >> ~/.ssh/known_hosts'
                sh 'ssh jenkins@213.32.14.59 << EOF\n' +
                    'cd /home/jenkins/MobileInvoiceTest/OrangeMoney/MobileInvoice/\n' +
                    'git reset --hard HEAD\n' +
                    'git checkout develop\n' +
                    'git fetch\n' +
                    'git reset --hard HEAD\n' +
                    'git merge origin/develop\n' +
                    'cd /home/jenkins/MobileInvoiceTest/OrangeMoney/MobileInvoice/\n' +
                    'mv docker-compose-dev.yml docker-compose.yml\n' +
                    'sudo su\n' +
                    'docker-compose down\n' +
                    'docker-compose up -d\n' +
                    'exit\n' +
                    'EOF'
            }
        }
        
        stage('WAF - Web Application Firewall') {
            steps {
                // Configuration du WAF pour protéger l'application Web
                // Assurez-vous d'installer et de configurer le WAF sur le serveur Web ici
                sh 'openappsec enable your-app-url.com || true'
            }
        }

        stage('Performance Tests') {
            steps {
                // Exemple de commandes pour exécuter des tests de performance avec JMeter pour une application Web
                // Assurez-vous que les tests de performance ne surchargent pas le serveur cible
                sh 'jmeter -n -t path/to/jmeter_script.jmx -l jmeter_results.jtl'
            }
        }

        stage('DAST') {
            steps {
                // Exemple de commandes pour exécuter des tests de sécurité dynamiques avec OWASP ZAP pour une application Web
                sh 'docker run -t owasp/zap2docker-stable zap-baseline.py -t http://your-app-url.com'
            }
        }

        stage('Release') {
            steps {
                // Exemple de commandes pour publier l'application dans un repository ou une plateforme de distribution
                sh 'mvn deploy'
            }
        }
    }

    post {
        success {
            // Actions à effectuer en cas de succès du pipeline
            // Par exemple : notifier l'équipe de développement, déployer sur l'environnement de production, etc.
            sh 'echo "CI/CD pipeline succeeded!"'
        }
        failure {
            // Actions à effectuer en cas d'échec du pipeline
            // Par exemple : notifier l'équipe de développement, envoyer des alertes, etc.
            sh 'echo "CI/CD pipeline failed!"'
        }
    }
}



