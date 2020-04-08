def image = "php-test" 

pipeline {
    agent any 
       stages {
         stage('Cloning dockerfiles, configs and others...') {
            steps {
              checkout([$class: 'GitSCM', branches: [[name: 'origin/master']],
              userRemoteConfigs: [[url: 'https://github.com/chillivilli/labs.git']]])  
              echo 'Pulling2..' + env.BRANCH_NAME
            }
         }
         stage('Build and run docker container ') {
             steps {
               script{
                   docker.build("${image}:${env.BUILD_ID}", '--build-arg BRANCH_NAME="${GIT_BRANCH#*/}" .')
                   docker.image("${image}:${env.BUILD_ID}").run()
                   docker.image("${image}:${env.BUILD_ID}").inside() {sh "uptime"}              
               }
             }
         }
         stage('Run tests in container') {
             parallel(UnitTest: {
                steps {
                  script { 
                   docker.image("${image}:${env.BUILD_ID}").inside() {sh 'echo "$BRANCH_NAME"'}
                }
             }  
         }, LoadTest: {
                steps {
                  script { 
                   docker.image("${image}:${env.BUILD_ID}").inside() {sh 'echo "$BRANCH_NAME"'}
                }
             }  
})
             steps {
               script { 
                   docker.image("${image}:${env.BUILD_ID}").inside() {sh 'echo "$BRANCH_NAME"'}
                }
             }  
        } 
    }
    
    post { 
        always { 
            cleanWs()
        }
    }    
}
