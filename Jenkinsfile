//Pipeline for full DEVOPS:
pipeline {
    agent any
	
    tools {
       maven 'maven'
    }
	
    stages {	
        stage ('Artifactory configuration') {
            steps {
		slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Pipeline build ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                rtServer (
                    id: 'Artifactory',
                    url: 'https://jfrogjenkins.jfrog.io/artifactory',
                    credentialsId: 'artifactory'
                )
		rtMavenResolver (
		    id: 'resolver-artifactory',
		    serverId: 'Artifactory',
		    releaseRepo: 'libs-release',
		    snapshotRepo: 'libs-snapshot'
		)  

		rtMavenDeployer (
		    id: 'deployer-artifactory',
		    serverId: 'Artifactory',
		    releaseRepo: 'libs-release-local',
		    snapshotRepo: 'libs-snapshot-local',
		    // By default, 3 threads are used to upload the artifacts to Artifactory. You can override this default by setting:
		    threads: 6,
		)		    
            }
        }	    
        stage('SCM - GIT Commit') {
            steps {
                // Get some code from a GitHub repository
                git credentialsId: 'github', url: 'git@github.com:venkatasubramanian18/DevOps-Demo-WebApp.git'				
            }
        }
//       stage('Code Analysis - SonarQube') {
//		steps {
//			withSonarQubeEnv(credentialsId: 'sonar', installationName: 'sonarqube') { 
//				sh 'mvn clean package sonar:sonar -Dsonar.host.url=http://23.100.47.167:9000 -Dsonar.sources=. -Dsonar.tests=. -Dsonar.inclusions=**/test/java/servlet/createpage_junit.java -Dsonar.test.exclusions=**/test/java/servlet/createpage_junit.java -Dsonar.login=admin -Dsonar.password=admin'
//			}
//		}
//	}
	stage('Build - Maven') {
		steps {
//			sh 'mvn clean install'
			 withMaven(
				// Maven installation declared in the Jenkins "Global Tool Configuration"
				maven: 'maven',
				// Maven settings.xml file defined with the Jenkins Config File Provider Plugin
				// Maven settings and global settings can also be defined in Jenkins Global Tools Configuration
				//mavenSettingsConfig: 'my-maven-settings',
				mavenLocalRepo: '.m2'
			)
			rtMavenRun (
			    // Tool name from Jenkins configuration.
			    tool: 'maven',
			    pom: 'pom.xml',
			    //goals: 'clean install -Dmaven.repo.local=.m2',
			    goals: 'clean install',
			    // Maven options.
			    opts: '-Xms1024m -Xmx4096m',
			    resolverId: 'resolver-artifactory',
			    deployerId: 'deployer-artifactory'
//			    // If the build name and build number are not set here, the current job name and number will be used:
			)
			slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Build Success ${env.JOB_NAME} ${env.BUILD_NUMBER}"
		}
   	}
     	stage('Store the Artifacts') {
		steps {
			rtPublishBuildInfo (
			    serverId: 'Artifactory'
			)
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
//	stage('Perform UI Test - Publish Report') {
//		steps{
//			script {
//			  sh 'mvn -f functionaltest/pom.xml package'
//			  sh 'mvn package test'
//			  publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\functionaltest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'UI Test Report', reportTitles: ''])
//			}
//		}
//	}
	    
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
	    
//	stage('Perform Sanity Test - Publish Report') {
//		steps{
//			script {
//			     sh 'mvn -f Acceptancetest/pom.xml package'
//			     sh 'mvn package test'
//			     publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\Acceptancetest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'Sanity Test Report', reportTitles: ''])
//			     slackSend channel: '#devops', tokenCredentialId: 'slacktoken', message: "Perform Sanity Test - Publish Report ${env.JOB_NAME} ${env.BUILD_NUMBER}"
//			}
//		}
//	 }	 	    
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
