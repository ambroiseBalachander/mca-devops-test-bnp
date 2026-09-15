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

        // --- Stage 0 : Connexion GHCR uniquement (outils déjà intégrés dans l'image agent) ---
        stage('Login GHCR') {
            steps {
                container('buildah') {
                    sh 'echo "$GHCR_CREDS_PSW" | buildah login ghcr.io -u "$GHCR_CREDS_USR" --password-stdin'
                }
            }
        }

        // --- Stage 1 : Scans statiques ---
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

        // --- Stage 2 : Build, SBOM, SCA & Push ---
        stage('Build & Image Scans') {
            parallel {
                
                // Pipeline Backend
                stage('Backend Pipeline') {
                    steps {
                        container('buildah') {
                            sh 'buildah build --tag $BACKEND_IMAGE ./backend'
                            sh 'buildah push $BACKEND_IMAGE oci-archive:backend-image.tar'
                            sh 'syft oci-archive:backend-image.tar -o cyclonedx-json > backend-sbom.json'
                            sh 'grype sbom:./backend-sbom.json --fail-on critical'
                            sh 'buildah push $BACKEND_IMAGE docker://$BACKEND_IMAGE'
                            sh 'rm -f backend-image.tar'
                        }
                    }
                }

                // Pipeline Frontend
                stage('Frontend Pipeline') {
                    steps {
                        container('buildah') {
                            sh 'buildah build --tag $FRONTEND_IMAGE ./frontend'
                            sh 'buildah push $FRONTEND_IMAGE oci-archive:frontend-image.tar'
                            sh 'syft oci-archive:frontend-image.tar -o cyclonedx-json > frontend-sbom.json'
                            sh 'grype sbom:./frontend-sbom.json --fail-on critical'
                            sh 'buildah push $FRONTEND_IMAGE docker://$FRONTEND_IMAGE'
                            sh 'rm -f frontend-image.tar'
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