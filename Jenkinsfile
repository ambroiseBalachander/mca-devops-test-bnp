pipeline {
    agent { 
        node {
            label 'buildah'
        }
    }

    environment {
        REGISTRY = 'registry.registry.svc.cluster.local:5000'
        BACKEND_IMAGE = "${REGISTRY}/backend:${BUILD_NUMBER}"
        FRONTEND_IMAGE = "${REGISTRY}/frontend:${BUILD_NUMBER}"
    }

    stages {

        // --- Stage 0 : Outils de sécurité ---pipeline {
    agent { label 'buildah' }

    environment {
        REGISTRY = 'registry.registry.svc.cluster.local:5000'
        BACKEND_IMAGE = "${REGISTRY}/mca-backend:${BUILD_NUMBER}"
        FRONTEND_IMAGE = "${REGISTRY}/mca-frontend:${BUILD_NUMBER}"
    }

    stages {
        stage('Préparation des outils') {
            steps {
                // À déplacer idéalement directement dans l'image Docker de l'agent Jenkins
                sh '''
                    command -v gitleaks >/dev/null || curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/install.sh | sh -s -- -b /usr/local/bin
                    command -v syft >/dev/null || curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
                    command -v grype >/dev/null || curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
                    command -v semgrep >/dev/null || pip install semgrep --break-system-packages --quiet
                '''
            }
        }

        stage('Scans de sécurité statiques') {
            parallel {
                stage('Secrets') {
                    steps {
                        sh 'gitleaks detect --source . --no-git --exit-code 1'
                    }
                }
                stage('SAST') {
                    steps {
                        sh 'semgrep --config auto --error .'
                    }
                }
            }
        }

        stage('Build & SCA') {
            parallel {
                stage('Backend') {
                    steps {pipeline {
    agent { label 'buildah' }

    environment {
        REGISTRY = 'registry.registry.svc.cluster.local:5000'
        BACKEND_IMAGE = "${REGISTRY}/mca-backend:${BUILD_NUMBER}"
        FRONTEND_IMAGE = "${REGISTRY}/mca-frontend:${BUILD_NUMBER}"
    }

    stages {
        stage('Préparation des outils') {
            steps {
                // À déplacer idéalement directement dans l'image Docker de l'agent Jenkins
                sh '''
                    command -v gitleaks >/dev/null || curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/install.sh | sh -s -- -b /usr/local/bin
                    command -v syft >/dev/null || curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
                    command -v grype >/dev/null || curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
                    command -v semgrep >/dev/null || pip install semgrep --break-system-packages --quiet
                '''
            }
        }

        stage('Scans de sécurité statiques') {
            parallel {
                stage('Secrets') {
                    steps {
                        sh 'gitleaks detect --source . --no-git --exit-code 1'
                    }
                }
                stage('SAST') {
                    steps {
                        sh 'semgrep --config auto --error .'
                    }
                }
            }
        }

        stage('Build & SCA') {
            parallel {
                stage('Backend') {
                    steps {
                        sh 'buildah build --tag $BACKEND_IMAGE ./backend'
                        sh 'syft $BACKEND_IMAGE -o cyclonedx-json > backend-sbom.json'
                        sh 'grype sbom:./backend-sbom.json --fail-on critical'
                        sh 'buildah push --tls-verify=false $BACKEND_IMAGE docker://$BACKEND_IMAGE'
                    }
                }
                stage('Frontend') {
                    steps {
                        sh 'buildah build --tag $FRONTEND_IMAGE ./frontend'
                        sh 'syft $FRONTEND_IMAGE -o cyclonedx-json > frontend-sbom.json'
                        sh 'grype sbom:./frontend-sbom.json --fail-on critical'
                        sh 'buildah push --tls-verify=false $FRONTEND_IMAGE docker://$FRONTEND_IMAGE'
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
                        sh 'buildah build --tag $BACKEND_IMAGE ./backend'
                        sh 'syft $BACKEND_IMAGE -o cyclonedx-json > backend-sbom.json'
                        sh 'grype sbom:./backend-sbom.json --fail-on critical'
                        sh 'buildah push --tls-verify=false $BACKEND_IMAGE docker://$BACKEND_IMAGE'
                    }
                }
                stage('Frontend') {
                    steps {
                        sh 'buildah build --tag $FRONTEND_IMAGE ./frontend'
                        sh 'syft $FRONTEND_IMAGE -o cyclonedx-json > frontend-sbom.json'
                        sh 'grype sbom:./frontend-sbom.json --fail-on critical'
                        sh 'buildah push --tls-verify=false $FRONTEND_IMAGE docker://$FRONTEND_IMAGE'
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
        stage('Install Security Tools') {
            steps {
                container('buildah') {
                    sh '''
                        # Installation conditionnelle (évite le surcoût si déjà présents)
                        command -v gitleaks >/dev/null || curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/install.sh | sh -s -- -b /usr/local/bin
                        command -v syft >/dev/null || curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
                        command -v grype >/dev/null || curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
                        command -v semgrep >/dev/null || pip install semgrep --break-system-packages --quiet
                    '''
                }
            }
        }

        // --- Stage 1 : Scans statiques ---
        stage('Static Security Scans') {
            parallel {
                stage('Secrets Scan') {
                    steps {
                        container('buildah') {
                            sh 'gitleaks detect --source . --no-git --exit-code 1'
                        }
                    }
                }
                stage('SAST') {
                    steps {
                        container('buildah') {
                            sh 'semgrep --config auto --error .'
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
                            sh 'buildah push --tls-verify=false $BACKEND_IMAGE docker://$BACKEND_IMAGE'
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
                            sh 'buildah push --tls-verify=false $FRONTEND_IMAGE docker://$FRONTEND_IMAGE'
                        }
                    }
                }

            }
        }
    }

    post {
        always {
            // Archivage des SBOMs générés
            archiveArtifacts artifacts: '*-sbom.json', allowEmptyArchive: true
        }
    }
}