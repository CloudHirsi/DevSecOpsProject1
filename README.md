# End To End DevSecOps Project!
TOOLS:
- Terraform
- Azure (Environment + AKS, Azure Container Registry, Azure Monitor)
- Jenkins (Pipeline)
- SonarQube (SAST Scanning)
- Trivy (file and image scanning)
- Docker (Containers/Containerizing)
- Kubernetes (Container Orchestration)
- **Splunk** (Monitoring, Visualization and Data Collection)
- Email Notifications!

## Terraform Configuration:
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/c574d72d-69cd-4046-9938-d8eb870fbfa5)

## Jenkins Pipeline:
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/0f53cc60-c377-47e9-a758-190da2de8a5b)

``` 
pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        registryName = "$ACRNAME"
        registryCredential = '$ACR'
        registryUrl = '$AZURECONTAINERREGISTRY'
    }
    stages {
        stage('clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage('checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/CloudHirsi/youtube-app']]])
            }
        }
        stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=DevSecOpsProject \
                    -Dsonar.projectKey=DevSecOpsProject'''
                }
            }
        }
        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: '$SONARQUBETOKEN'
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
                    dockerImage = docker.build '$IMAGE:latest'
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
                script {
                    sh "docker login projectacr678.azurecr.io -u ProjectACR678 -p sgBqFOeYDAi7yjzGqM/0uVk6H2ijnsO2ywVl1d3wvB+ACRCgRMys"
                    sh "docker pull $IMAGE:latest"
                    docker.image('aquasec/trivy').run("--rm $IMAGE:latest > trivyimage.txt")
        }
    }
}


        stage('K8 Deploy') {
            steps {
                script {
                    withKubeConfig(credentialsId: 'K8', serverUrl:'$SERVERURL') {
                        sh "kubectl apply -f deployment.yaml"
                        sh "kubectl apply -f service.yaml"
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
## SonarQube Quality Gate:
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/ccc680f5-5606-4d38-ac95-062cc1c5bb3c)

## Working App and Services:
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/b7ebff40-0ba2-4ccf-8738-de0d97ac94ed)

## Monitoring in AzureMonitor
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/242f5e5a-1970-435c-a21f-c32f6c98d1ff)
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/767a8970-affd-4598-81b1-8b5b1c30a85a)

## Monitoring sent to **Splunk**
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/c7c7fcc5-d55e-4ae6-91bd-8b8f7cef06ca)

## Success Email Notification: 
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/a46a6e16-56a4-4dd9-9089-45e6cd240e23)

## Terraform Destroy + Cleanup :)
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/0b544e75-bce5-4a42-92a2-ace270f1ae18)











