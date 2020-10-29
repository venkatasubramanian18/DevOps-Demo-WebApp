//Pipeline for full DEVOPS:
pipeline {
    environment {
	registry = "devopstraining18/mavenbuild"
	registryCredential = 'dockerhub'
	dockerImage = ''
	def server = Artifactory.server "artifactory"
	def rtMaven = Artifactory.newMavenBuild()
	def buildInfo = Artifactory.newBuildInfo()
    }	
	
    agent any
	
    tools {
       maven 'maven'
    }
	
    stages {	
//        stage ('Artifactory configuration') {
//            steps {
//		slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Pipeline build ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
//                rtServer (
//                   id: 'Artifactory',
//                   url: 'https://devops111.jfrog.io',
//                   credentialsId: 'artifactory'
//                )
//		rtMavenResolver (
//		    id: 'resolver-artifactory',
//		    serverId: 'Artifactory',
//		    releaseRepo: 'libs-release',
//		    snapshotRepo: 'libs-snapshot'
//		)  
//		rtMavenDeployer (
//		    id: 'deployer-artifactory',
//		    serverId: 'Artifactory',
//		    deployArtifacts: false,
//		    releaseRepo: 'libs-release-local',
//		    snapshotRepo: 'libs-snapshot-local',
//		    // By default, 3 threads are used to upload the artifacts to Artifactory. You can override this default by setting:
//		    threads: 6
//		)
//            }	
//	}			
        stage('SCM - GIT Commit') {
            steps {
                // Get some code from a GitHub repository
                git credentialsId: 'github', url: 'git@github.com:venkatasubramanian18/DevOps-Demo-WebApp.git'	
		slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Pipeline build Started ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            }
        }
//       stage('Code Analysis - SonarQube') {
//		steps {
//			withSonarQubeEnv(credentialsId: 'sonar', installationName: 'sonarqube') { 
//				sh 'mvn clean package sonar:sonar -Dsonar.host.url=http://23.100.47.167:9000 -Dsonar.sources=. -Dsonar.tests=. -Dsonar.inclusions=**/test/java/servlet/createpage_junit.java -Dsonar.test.exclusions=**/test/java/servlet/createpage_junit.java -Dsonar.login=admin -Dsonar.password=admin'
//			}
//			slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "SonarQube Analysis Succeed ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
//		}
//	}
//	stage('Build - Maven') {
//		steps {
//			sh 'mvn clean install'
//			rtMavenRun (
//			    // Tool name from Jenkins configuration.
//			    tool: 'maven',
//			    pom: 'pom.xml',
//			    goals: 'clean install -e -o',
//			    //goals: 'clean install',
//			    // Maven options.
//			    opts: '-Xms1024m -Xmx4096m',
//			    resolverId: 'resolver-artifactory',
//			    deployerId: 'deployer-artifactory'
//			    // If the build name and build number are not set here, the current job name and number will be used:
//			)			
//			slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Build Success ${env.JOB_NAME} ${env.BUILD_NUMBER}"
//		}
// 	}
	stage('Build - Docker Image') {
		steps {
			script {
          			dockerImage = docker.build registry + ":$BUILD_NUMBER"
        		}
		}
   	}	  
    	stage('Push - Docker Image') {
      		steps{    
          		script {
              			docker.withRegistry( '', registryCredential ) {
                		dockerImage.push()
              			}
          		}
			slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Docker Image Push Success ${env.JOB_NAME} ${env.BUILD_NUMBER}"
      		}
    	}  
     	stage('Store the Artifacts') {
		parallel {
			stage('Config') {
				steps {
					script {
						//def server = Artifactory.server "artifactory"
						//def rtMaven = Artifactory.newMavenBuild()
						//def buildInfo = Artifactory.newBuildInfo()
						rtMaven.tool = "maven"
						rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-snapshot-local', server: server
		     				rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
		   				rtMaven.deployer.deployArtifacts = false // Disable artifacts deployment during Maven run

					}
				}
			}
			stage('Build') {
				steps {
		//			rtPublishBuildInfo (
		//			    serverId: 'Artifactory'
		//			)
					script {
		//				def server = Artifactory.server "artifactory"
		//				def rtMaven = Artifactory.newMavenBuild()
		//				def buildInfo = Artifactory.newBuildInfo()
		//				rtMaven.tool = "maven"
		//				rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-snapshot-local', server: server
		//      			rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
		//    				rtMaven.deployer.deployArtifacts = false // Disable artifacts deployment during Maven run
						buildInfo = rtMaven.run pom: 'pom.xml', goals: 'clean install -e', buildInfo: buildInfo
						server.publishBuildInfo buildInfo
					}
				}
			}			
		}
 	}    	    
				
    	stage('Deploy to Test') {
		steps{
			script {
				deploy adapters: [tomcat8(credentialsId: 'tomcat', path: '', url: 'http://23.101.207.158:8080/')], contextPath: '/QAWebapp', war: '**/*.war'	
				slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Deployed to Test ${env.JOB_NAME} ${env.BUILD_NUMBER}"					
			}			
		}
   	}	
	stage('Perform UI Test - Publish Report') {
		steps{
			script {
			  sh 'mvn -f functionaltest/pom.xml package'
			  sh 'mvn package test'
			  publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\functionaltest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'UI Test Report', reportTitles: ''])
			}
		}
	}
	    
//	stage('Performance Test - Blazemeter') {
//		steps{
//	   		blazeMeterTest credentialsId: 'Blazemeter', testId: '8626535.taurus', workspaceId: '677291'
//	    		slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Performance Test - Blazemeter ${env.JOB_NAME} ${env.BUILD_NUMBER}"
//		}
//	}	  

	stage('Deploy to Prod') {
		steps{
	     		deploy adapters: [tomcat8(credentialsId: 'tomcat', path: '', url: 'http://51.141.177.121:8080/')], contextPath: '/ProdWebapp', war: '**/*.war'	
			slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Deployed to Prod ${env.JOB_NAME} ${env.BUILD_NUMBER}"	    
		}
	}	
	    
	stage('Perform Sanity Test - Publish Report') {
		steps{
			script {
			     sh 'mvn -f Acceptancetest/pom.xml package'
			     sh 'mvn package test'
			     publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\Acceptancetest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'Sanity Test Report', reportTitles: ''])
			     slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Perform Sanity Test - Publish Report ${env.JOB_NAME} ${env.BUILD_NUMBER}"
			}
		}
	 }	 	    
    }
    post {
	success {
		echo 'All stages ran successfully'
	}
	failure {
		echo 'Failed in some stage'
	}
    }
}
