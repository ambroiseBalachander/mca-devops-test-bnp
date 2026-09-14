pipeline {
    agent {
        label 'buildah'
    }

    environment {
        REGISTRY = 'ghcr.io/ambroisebalachander'
        BACKEND_IMAGE = "${REGISTRY}/mca-backend:${BUILD_NUMBER}"
        FRONTEND_IMAGE = "${REGISTRY}/mca-frontend:${BUILD_NUMBER}"
        GHCR_CREDS = credentials('ghcr-credentials')
    }

    stages {

        // --- Stage 0 : Outils de sécurité & Authentification GHCR ---
        stage('Install Security Tools & Login') {
            steps {
                container('buildah') {
                    sh '''
                        # Installation des outils de sécurité
                        command -v gitleaks >/dev/null || curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/install.sh | sh -s -- -b /usr/local/bin
                        command -v syft >/dev/null || curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
                        command -v grype >/dev/null || curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
                        command -v semgrep >/dev/null || pip install semgrep --break-system-packages --quiet

                        # Connexion sécurisée à GHCR
                        echo "$GHCR_CREDS_PSW" | buildah login ghcr.io -u "$GHCR_CREDS_USR" --password-stdin
                    '''
                }
            }
        }

        // --- Stage 1 : Scans statiques (uniquement frontend/ et backend/) ---
        stage('Static Security Scans') {
            parallel {
                stage('Secrets Scan') {
                    steps {
                        container('buildah') {
                            sh 'gitleaks detect --source frontend/ --no-git --exit-code 1'
                            sh 'gitleaks detect --source backend/ --no-git --exit-code 1'
                        }
                    }
                }
                stage('SAST') {
                    steps {
                        container('buildah') {
                            sh 'semgrep --config auto --error backend/ frontend/'
                        }
                    }
                }
            }
        }

        // --- Stage 2 : Build, SBOM, SCA & Push en parallèle ---
        stage('Build & Image Scans') {
            parallel {
                
                // Pipeline Backend
                stage('Backend Pipeline') {
                    steps {
                        container('buildah') {
                            sh 'buildah build --tag $BACKEND_IMAGE ./backend'
                            sh 'syft $BACKEND_IMAGE -o cyclonedx-json > backend-sbom.json'
                            sh 'grype sbom:./backend-sbom.json --fail-on critical'
                            sh 'buildah push $BACKEND_IMAGE docker://$BACKEND_IMAGE'
                        }
                    }
                }

                // Pipeline Frontend
                stage('Frontend Pipeline') {
                    steps {
                        container('buildah') {
                            sh 'buildah build --tag $FRONTEND_IMAGE ./frontend'
                            sh 'syft $FRONTEND_IMAGE -o cyclonedx-json > frontend-sbom.json'
                            sh 'grype sbom:./frontend-sbom.json --fail-on critical'
                            sh 'buildah push $FRONTEND_IMAGE docker://$FRONTEND_IMAGE'
                        }
                    }
                }

            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '*-sbom.json', allowEmptyArchive: true
        }
    }
}