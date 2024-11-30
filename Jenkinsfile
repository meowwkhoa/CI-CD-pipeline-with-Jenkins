// pipeline {
//     agent any

//     environment {
//         registry = '730335374737.dkr.ecr.us-east-1.amazonaws.com/group12' // AWS ECR registry
//         awsRegion = 'us-east-1'
//     }

//     stages {
//         stage('Checkout') {
//             steps {
//                 // Checkout the repository
//                 checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/meowwkhoa/CI-CD-pipeline-with-Jenkins']])
//             }
//         }

//         // stage('Test') {
//         //     agent {
//         //         docker {
//         //             image 'python:3.8' 
//         //         }
//         //     }
//         //     steps {
//         //         echo 'Testing FastAPI model correctness..'
//         //         sh 'sudo pip install -r requirements.txt && sudo pytest'  // Install dependencies and run tests
//         //     }
//         // }

//         stage('Build Docker Image') {
//             steps {
//                 script {
//                     echo 'Building image for FastAPI app deployment..'
//                     dockerImage = docker.build registry 
//                     dockerImage.tag("$BUILD_NUMBER")
//                 }
//             }
//         }

//         stage('Push to ECR') {
//             steps {
//                 script {
//                     echo 'Pushing image to AWS ECR..'
//                     // Login to AWS ECR
//                     sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 730335374737.dkr.ecr.us-east-1.amazonaws.com'
//                     // Push the Docker image to ECR
//                     sh 'docker push 730335374737.dkr.ecr.us-east-1.amazonaws.com/group12:$BUILD_NUMBER'
//                 }
//             }
//         }

//         stage('Deploy with Helm') {
//             steps {
//                 echo 'Deploying FastAPI app with Helm..'
//                 sh "helm upgrade first --install deployment-helmchart --namespace model-serving --set image.tag=$BUILD_NUMBER"  // Deploy using Helm
//             }
//         }
//     }
// }

pipeline {
    agent any

    environment {
        registry = '891377192403.dkr.ecr.us-east-1.amazonaws.com/group12'
        awsRegion = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/meowwkhoa/CI-CD-pipeline-with-Jenkins']])
            }
        }

        stage('Build and Push Image') {
            steps {
                script {
                    echo 'Building and pushing FastAPI app image..'
                    dockerImage = docker.build registry 
                    dockerImage.tag("$BUILD_NUMBER")
                    sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 891377192403.dkr.ecr.us-east-1.amazonaws.com'
                    sh 'docker push 891377192403.dkr.ecr.us-east-1.amazonaws.com/group12:$BUILD_NUMBER'
                }
            }
        }

        stage('Deploy FastAPI') {
            steps {
                echo 'Deploying FastAPI app with Helm..'
                sh "helm upgrade first --install deployment-helmchart --namespace model-serving --set image.tag=$BUILD_NUMBER"
            }
        }

    }
}
