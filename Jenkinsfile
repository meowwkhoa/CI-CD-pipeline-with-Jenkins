// pipeline {
//     agent any

//     environment{
//         registry = 'khoatomato/house-price-prediction'
//         registryCredential = 'dockerhub'
//     }

//     stages {
//         stage('Deploy') {
//             agent {
//                 kubernetes {
//                     containerTemplate {
//                         name 'helm' // Name of the container to be used for helm upgrade
//                         image 'khoatomato/jenkins:0.0.1' // The image containing helm
//                         alwaysPullImage true // Always pull image in case of using the same tag
//                     }
//                 }
//             }
//             steps {
//                 script {
//                     container('helm') {
//                         sh("helm upgrade --install hpp ./helm-charts/hpp --namespace model-serving")
//                     }
//                 }
//             }
//         }
//     }
// }


pipeline {
    agent any

    options{
        // Max number of build logs to keep and days to keep
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
        // Enable timestamp at each job in the pipeline
        timestamps()
    }

    environment{
        registry = 'khoatomato/house-price-prediction'
        registryCredential = 'dockerhub'
    }

    stages {
        stage('Test') {
            agent {
                docker {
                    image 'python:3.8' 
                }
            }
            steps {
                echo 'Testing model correctness..'
                sh 'pip install -r requirements.txt && pytest'
            }
        }
        stage('Build') {
            steps {
                script {
                    echo 'Building image for deployment..'
                    dockerImage = docker.build registry + ":$BUILD_NUMBER" 
                    echo 'Pushing image to dockerhub..'
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('Deploy') {
            agent {
                kubernetes {
                    containerTemplate {
                        name 'helm' // Name of the container to be used for helm upgrade
                        image 'khoatomato/jenkins:0.0.1' // The image containing helm
                        alwaysPullImage true // Always pull image in case of using the same tag
                    }
                }
            }
            steps {
                script {
                    container('helm') {
                        sh("helm upgrade --install hpp ./deployments/hpp --namespace model-serving")
                    }
                }
            }
        }
    }
}