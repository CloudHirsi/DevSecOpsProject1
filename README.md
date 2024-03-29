# End To End DevSecOps Project!
TOOLS:
- Terraform
- Azure (Environment + AKS, Azure Container Registry, Azure Monitor)
- Jenkins (Pipeline)
- SonarQube (SAST Scanning)
- Trivy (file and image scanning)
- Docker (Containers/Containerizing)
- Kubernetes (Container Orchestration)
- Splunk (Monitoring, Visualization and Data Collection)
- 

## Terraform Configuration:
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/c574d72d-69cd-4046-9938-d8eb870fbfa5)

## Jenkins Pipeline:
``` 
pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        registryName = "$REGISTRYNAME"
        registryCredential = '$ACR'
        registryUrl = '$REGISTRYURL'
    }
    stages {
        stage('clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage('checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: '$GITHUB']]])
            }
        }
        stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=$PROJECTNAME \
                    -Dsonar.projectKey=$PROJECTKEY'''
                }
            }
        }
        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: '$SonarQube-Token'
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build & Push") {
            steps {
                script {
                    dockerImage = docker.build '$ACRNAME'
                }
            }
        }
        stage('Upload Image to ACR') {
            steps {   
                script {
                    docker.withRegistry("http://${registryUrl}", registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }
        stage("TRIVY Image Scan") {
            steps {
                sh "trivy image $ACRIMAGE:latest > trivyimage.txt" 
            }
        }
        stage('K8S Deploy') {
            steps {
                script {
                    withKubeConfig(credentialsId: 'K8S', serverUrl:'$SERVERURL') {
                        sh 'kubectl apply -f deployment.yaml'
                        sh 'kubectl apply -f service.yaml'
                    }
                }
            }
        }
    }
    post {
        always {
            emailext attachLog: true,
                subject: "'${currentBuild.result}'",
                body: "Project: ${env.JOB_NAME}<br/>" +
                    "Build Number: ${env.BUILD_NUMBER}<br/>" +
                    "URL: ${env.BUILD_URL}<br/>",
                to: 'hamidhirsi7@gmail.com',                              
                attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
        }
    }
}
```
# Security Results:
## SonarQube:
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/5aac046e-02d9-4f2b-8bf9-b750b2827c7c)

## Trivy:




