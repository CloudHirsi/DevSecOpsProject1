# _DevSecOps Automation + Monitoring for Site Reliability!_
## **Architecture:**
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/2c5b5e51-6a60-48ca-bd4b-353242ef15fd)


TOOLS:
- Terraform
- Azure (Environment + AKS, Azure Container Registry, Azure Monitor)
- Jenkins (Pipeline)
- SonarQube (SAST Scanning)
- Trivy (vulnerability and image scanning)
- Docker (Containers/Containerizing)
- Kubernetes (Container Orchestration)
- Helm Charts (installations and deployment)
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

## Monitoring in Azure Monitor:
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/8fd91816-47a4-42ce-9f00-0567f24b341a)


## Monitoring using **SPLUNK**
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/59fcba2c-5314-4ed6-bd8e-06cc4f27d357)
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/ff9d107a-956d-4bd8-979c-8026980ef20c)

## Success Email Notification: 
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/a46a6e16-56a4-4dd9-9089-45e6cd240e23)

## Terraform Destroy + Cleanup :)
![image](https://github.com/CloudHirsi/DevSecOpsProject1/assets/153539293/0b544e75-bce5-4a42-92a2-ace270f1ae18)

# **Evaluation:**

*Project: DevSecOps Automation + Monitoring for Site Reliability*

## Situation:

I initiated a DevSecOps Automation project to streamline the development, deployment, and security processes for cloud-native applications. The goal was to establish end-to-end automation using modern DevOps tools and practices whilst shifting security left of the CI/CD Pipeline.

## Tasks:

*Infrastructure Provisioning with Terraform:*
- Independently designed and implemented infrastructure as code using Terraform to create Azure resources, including Azure Container Registry and AKS clusters.

*CI/CD Pipeline Development with Jenkins:*
- Developed a comprehensive Jenkins Pipeline from scratch, incorporating stages for code analysis, dependency management, image scanning, and deployment to AKS.

*Static Code Analysis with SonarQube:*
- Integrated SonarQube for static code analysis to identify and address code quality issues and security vulnerabilities in the early stages of development.

*Image Scanning with Trivy:*
- Implemented Trivy for vulnerability scanning of Docker container images, ensuring that only secure images were deployed to production environments.

*Containerization with Docker:*
- Single-handedly containerized applications using Docker, simplifying deployment and ensuring consistency across different environments.

*Container Orchestration with Kubernetes:*
- Orchestrated containerized applications on AKS using Kubernetes, enabling seamless scaling, fault tolerance, and resource management.

*Deployment using Helm Charts:*
- Installed and deployed Splunk onto my Kubernetes cluster using Helm Charts

*Monitoring and Visualization with Splunk:*
- Configured Splunk for real-time monitoring, visualization, and log aggregation, enabling proactive monitoring and troubleshooting of application performance and security.

*Email Notifications:*
- Implemented email notifications in Jenkins to provide instant feedback on pipeline execution status, ensuring timely awareness of build results and issues.

## Results:
Through my efforts, I successfully:

- Established a fully automated DevSecOps pipeline for cloud-native applications.
- Enhanced code quality and security through automated code analysis (SAST) and vulnerability scanning.
- Achieved efficient deployment and management of containerized applications on Docker and Kubernetes.
- Improved visibility and monitoring capabilities for site reliability.

This project showcases my proficiency in designing, implementing, and managing end-to-end DevSecOps workflows using a variety of tools and techniques.
Through this experience, i have especially learnt more about container and container orchestration through Docker and Kubernetes, as well as site reliability through monitoring and visualization, allowing me to improve my skillset and knowledge in modern DevOps/SRE principles and security best practices.









