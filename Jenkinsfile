//Pipeline for DEVOPS:
pipeline {
    agent any
	
    tools {
       maven 'maven'
    }
	
    stages {
	    
        stage ('Artifactory configuration') {
            steps {
                rtServer (
                    id: "Artifactory",
                    url: "https://ansibledevops.jfrog.io/artifactory/",
                    credentialsId: "artifactory"
                )
		rtMavenResolver (
		    id: 'resolver-artifactory',
		    serverId: 'Artifactory',
		    releaseRepo: 'libs-release',
		    snapshotRepo: 'libs-snapshot'
		)  

		rtMavenDeployer (
		    id: 'deployer-artifactory',
		    serverId: 'artifactory',
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
                git credentialsId: 'GIT', url: 'https://github.com/venkatasubramanian18/DevOps-Demo-WebApp.git'
            }
        }
       stage('Code Analysis - SonarQube') {
		steps {
			withSonarQubeEnv(credentialsId: 'sonar', installationName: 'sonarqube') { 
				sh 'mvn clean package sonar:sonar -Dsonar.host.url=http://23.100.47.167:9000 -Dsonar.sources=. -Dsonar.tests=. -Dsonar.inclusions=**/test/java/servlet/createpage_junit.java -Dsonar.test.exclusions=**/test/java/servlet/createpage_junit.java -Dsonar.login=admin -Dsonar.password=admin'
			}
		}
	}
	stage('Build - Maven') {
		steps {
//			sh 'mvn clean install'
			rtMavenRun (
			    // Tool name from Jenkins configuration.
			    tool: 'maven',
			    pom: 'pom.xml',
			    goals: '-U clean install -e',
			    // Maven options.
			    opts: '-Xms1024m -Xmx4096m',
			    resolverId: 'resolver-artifactory',
			    deployerId: 'deployer-artifactory'
//			    // If the build name and build number are not set here, the current job name and number will be used:
//			)
		}
    	}
//     	stage('Store the Artifacts') {
//		steps {
//			rtPublishBuildInfo (
//			    serverId: 'Artifactory'
//			)
//		}
//   	}	    	    
    	stage('Deploy to Test') {
		steps{
			script {
				deploy adapters: [tomcat8(credentialsId: 'tomcat', path: '', url: 'http://23.101.207.158:8080/')], contextPath: '/QAWebapp', war: '**/*.war'				
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
	    
	stage('Performance Test - Blazemeter') {
		steps{
	   		blazeMeterTest credentialsId: 'Blazemeter', testId: '8626535.taurus', workspaceId: '677291'
		}
	}	  

	stage('Deploy to Prod') {
		steps{
	     		deploy adapters: [tomcat8(credentialsId: 'tomcat', path: '', url: 'http://51.141.177.121:8080/')], contextPath: '/ProdWebapp', war: '**/*.war'		
		}
	}	
	    
	stage('Perform Sanity Test - Publish Report') {
		steps{
			script {
			     sh 'mvn -f Acceptancetest/pom.xml package'
			     sh 'mvn package test'
			     publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\Acceptancetest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'Sanity Test Report', reportTitles: ''])
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
