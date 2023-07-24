#!/bin/bash
# Script pour lancer l'analyse de sécurité avec ZAP
docker run -t owasp/zap2docker-stable zap-baseline.py -t http://localhost:8080/webapp/ || true
