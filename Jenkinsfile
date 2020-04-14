#!/usr/bin/env groovy

def image         = "php-test-ms"
def imageidInside = "${image}:${env.BRANCH_NAME}-${env.BUILD_ID}"
def branchId      = "${env.BRANCH_NAME} ${env.BUILD_ID}"
def registry      = "privateregystry.local/php-test-ms"
def credentials   = "secret"

pipeline {
    agent any
       stages {
         stage('Cloning dockerfiles, configs and others...') {
            steps {
              checkout([$class: 'GitSCM', branches: [[name: 'origin/master']],
              userRemoteConfigs: [[url: 'https://github.com/chillivilli/labs.git']]])
              echo 'Successfully pulling branch: '+"${branchId}"
            }
         }
         stage('Clean redis cache on all test env instances') {
             when {
                branch 'develop'
             }
             steps {
                sh "ansible -i hosts redis-test-env -m command -a '/usr/bin/redis-cli FLUSHALL'"
              }
         }
         stage('Clean redis cache on all stage env instances') {
             when {
                branch 'master'
             }
             steps {
                sh 'ansible -i hosts redis-stage-env -m command -a \'/usr/bin/redis-cli FLUSHALL\''
              }
         }
         stage('Build and some test container with test arg') {
             when {
               branch 'develop'
              }
                   steps {
                     script{
                          def imagePush = docker.build("${image}:${env.BUILD_ID}", "--build-arg BRANCH_NAME=${env.BRANCH_NAME} --build-arg ENV=test .")
                        // docker.image("${image}:${env.BUILD_ID}").run()
                          docker.image("${image}:${env.BUILD_ID}").inside() {
                          sh "hostname && uptime "
                          sh 'echo '$ENV_VAR''
                   }
                 }
             }
         }
         stage('Build and some test container with prod arg') {
               when {
                 branch 'master'
               }
                   steps {
                     script{
                          def imagePush = docker.build("${image}:${env.BUILD_ID}", "--build-arg BRANCH_NAME=${env.BRANCH_NAME} --build-arg ENV=stage .")
                          // docker.image("${image}:${env.BUILD_ID}").run()
                          docker.image("${image}:${env.BUILD_ID}").inside() {
                          sh "uptime"
                          sh 'echo '$ENV_VAR''
                    }
                 }
             }
         }
         stage('DB Migrations on test env') {
             when {
                 branch 'develop'
             }
                 steps {
                    script {
                        docker.image("${image}:${env.BUILD_ID}").withRun() {
                        sh 'echo its DB migration, like bin/console doctrine:migrations:migrate'
                        sh 'exit 0'
                    }
                 }
             }
         }
         stage('DB Migrations on stage prod') {
            when {
               branch 'master'
            }
                steps {
                     script {
                        docker.image("${image}:${env.BUILD_ID}").withRun() {
                        sh 'echo its DB migration, like bin/console doctrine:migrations:migrate'
                        sh 'exit 0'
                    }
                 }
             }
         }
         stage('Run parallels tests in containers') {
            steps {
              parallel(
                UnitTest: {
                  script {
                    docker.image("${image}:${env.BUILD_ID}").inside() {
                        sh 'echo its a Unit test'
                        sh 'env'
                    }
                  }
                },
                FunctionTest: {
                  script {
                    docker.image("${image}:${env.BUILD_ID}").inside() {
                        sh 'echo its a Function Test'
                        sh 'env'
                        echo '\$BRANCH_NAME'
                    }
                  }
               },
               OtherTest: {
                   script {
                       docker.image("${image}:${env.BUILD_ID}").inside(" -p 89:80 -e CHK=xm ") {
                        sh 'echo its a Regress or other Test'
                        sh 'env'
                        sh 'exit 0'
                    }
                   }
               }
             )
           }
        }
         stage('Run push image into private registry') {
             steps {
               echo '$hostname'
             }
         }
    }

    post {
        always {
            cleanWs()
            sh '''
            echo "Stop all containers"
            docker ps --all | grep '"${image}"' | awk '{print $1}'
            docker system prune -a -f
            '''
        }
    }
}
