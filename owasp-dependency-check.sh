#!/bin/bash

# Supprimer les fichiers précédents s'ils existent
rm -rf dependency-check-report.xml

# Exécuter OWASP Dependency-Check via Docker
docker run --rm -v "$PWD:/report" owasp/dependency-check --scan /report --format "XML" --out /report/dependency-check-report.xml
