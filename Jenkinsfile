pipeline {
    
    agent {label 'master'}
    environment 
    {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "nvwlminfjnkp001:8081"
        NEXUS_REPOSITORY = "jpetstoreapp"
        NEXUS_CREDENTIAL_ID = "nexus3"
        JPET = 'http://172.30.101.31:8990/jpetstore'
    }
    tools {
    maven 'M3'
         }
    options {
    timestamps()
    buildDiscarder(
        logRotator(
            // number of build logs to keep
            numToKeepStr:'5',
            // history to keep in days
            daysToKeepStr: '15',
            // artifacts are kept for days
            artifactDaysToKeepStr: '15',
            // number of builds have their artifacts kept
            artifactNumToKeepStr: '5'
        )
    )
}
    stages {
    
        stage('Code Checkout') 
    
        {
            steps{
                        echo("************************** Code Checkout Start**************************")
                              checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'gitlabpat', url: 'https://gitlab.dryicelabs.com/devops/jpetstore.git']]])
                        echo("************************** Code Checkout End****************************")
                  }

        }
        stage('Build Stage') 
        {
            steps{
                script{
                    echo("************************** Build  Start**************************")
                    sh "echo ${WORKSPACE}"
                    //sh "cd ${WORKSPACE}/jpetstore-6"
                    sh "mvn clean package"
                    echo("************************** Build  Completed**************************")
                     }
            }
            }
            stage('Code Scan with SonarQube') 
            {
                steps{
                    script{
                    sh "mvn -f pom.xml sonar:sonar -Dsonar.host.url=http://172.30.201.35:9000/sonar -Dsonar.login=admin -Dsonar.password=Admin098! -Dsonar.projectKey=jpetstoreapp -Dsonar.projectVersion=1.0 -Dsonar.projectName=jpetstoreapp"
                          }
                    }
            }
            stage("Publish to Nexus Repository Manager") 
            {
            steps {
                script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]
                        );
                    } else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }
        }
        stage("Deploy Stage") {
            steps{
                script{
                    sh "mvn install -DskipTests"
                    sh "mvn cargo:run -P tomcat90 &"
                    sh "echo Jpetstore webapp url is : ${JPET}"
                }
            }
        }       
    }//stages
    post{
        success{
            echo("************************** Application Started**************************")
            echo "Jpetstore webapp url is : ${JPET}"
            echo("************************** Application  Completed**************************")
        }
    }
}