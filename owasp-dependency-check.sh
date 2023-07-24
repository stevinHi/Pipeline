#!/bin/bash
# Script pour télécharger et exécuter DependencyCheck
rm owasp* || true
wget "https://raw.githubusercontent.com/RetireJS/retire.js/master/repository/jsrepository.json"
wget "https://raw.githubusercontent.com/jeremylong/DependencyCheck/master/bin/dependency-check.sh"
chmod +x owasp-dependency-check.sh
docker run --rm -v "$PWD:/report" owasp/dependency-check --scan /report --format "XML" --out /report/dependency-check-report.xml
cat dependency-check-report.xml
