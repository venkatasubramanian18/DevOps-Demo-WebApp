//Pipeline for full DEVOPS:
pipeline {
    environment {
	registry = "devopstraining18/mavenbuild"
	registryCredential = 'dockerhub'
	dockerImage = ''
	JfrogURL = 'https://devops111.jfrog.io/artifactory'	
	JfrogLogin = 'artifactory'
	rtServerID = 'artifactory'
	GitHubURL = 'git@github.com:venkatasubramanian18/DevOps-Demo-WebApp.git'
	GitHubLogin = 'github'
	SlackChannel = '#devops'
	SlackToken = 'slacktoken'
	JiraURL = 'jira-devops18.atlassian.net'
	JiraIssueKey = 'DD-3'
	JiraSiteForTransition = 'jirasite'
	SonarCredential = 'sonar'	
	SonarInstallationName = 'sonarqube'
	TomcatCredential = 'tomcat'
	TestDeployURL = 'http://23.101.207.158:8080/'	
	ProdDeployURL = 'http://51.141.177.121:8080/'
	BlazemeterCredential = 'Blazemeter'
	KubernetesCredential = "k8saccount"
	KubernetesProjectID = 'devops-294021'
	KubernetesClusterName = 'k8scluster'
	KubernetesZone = "us-west2-a"
    }	
	
    agent any
	
    tools {
       maven 'maven'
    }
	
    stages {	
//        stage('Artifactory configuration') {
//		steps {			
//			echo 'Artifact config'
//			ArtifactConfig()	
//		}
//	}
	    
        stage('SCM - GIT Commit') {
            steps {
                // Get some code from a GitHub repository
                git credentialsId: GitHubLogin, url: GitHubURL	
		slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Pipeline build Started ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            }
        }
	    
//        stage('Code Analysis - SonarQube') {
//		steps {
//			withSonarQubeEnv(credentialsId: SonarCredential, installationName: SonarInstallationName) { 
//				sh 'mvn clean package sonar:sonar -Dsonar.host.url=http://23.100.47.167:9000 -Dsonar.sources=. -Dsonar.tests=. -Dsonar.inclusions=**/test/java/servlet/createpage_junit.java -Dsonar.test.exclusions=**/test/java/servlet/createpage_junit.java -Dsonar.login=admin -Dsonar.password=admin'
//			}
//			slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "SonarQube Analysis Succeed ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
//		}
//	}
	stage('Build - Maven') {
		steps {		
			sh 'mvn clean install'
			//ArtifactRun()
			jiraTransitionIssue idOrKey: JiraIssueKey, input: [ transition: [ id: 21] ], site: JiraSiteForTransition
			jiraSendBuildInfo branch: JiraIssueKey, site: JiraURL			
			slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Build Success ${env.JOB_NAME} ${env.BUILD_NUMBER}"
		}
 	} 
    	stage('Test Server Deploy') {
		steps{
			script {
				deploy adapters: [tomcat8(credentialsId: TomcatCredential, path: '', url: TestDeployURL)], contextPath: '/QAWebapp', war: '**/*.war'	
				slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Deployed to Test ${env.JOB_NAME} ${env.BUILD_NUMBER}"	
				jiraComment body: "Deploy to Test was successfull ${env.JOB_NAME} ${env.BUILD_NUMBER}", issueKey: JiraIssueKey				
			}

		}
		post {
			always { 
			jiraSendDeploymentInfo environmentId: 'Test', environmentName: 'Test', serviceIds: [''], environmentType: 'testing', site: JiraURL, state: 'successful'
			}
		}
   	}
	stage('Store Artifact') {
		steps{
			StoreArtifact()
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
//	    
//	stage('Performance Test - Blazemeter') {
//		steps{
//	   		blazeMeterTest credentialsId: BlazemeterCredential, testId: '8626535.taurus', workspaceId: '677291'
//	    		slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Performance Test - Blazemeter ${env.JOB_NAME} ${env.BUILD_NUMBER}"
//		}
//	}	  

	stage('Deploy to Production') {
		parallel{
		        stage('Docker & Kubernetes'){
				stages{
					stage('Build Docker Image') {
						steps {
							script {
								echo registry + ":$BUILD_NUMBER"
								sh 'pwd'
								dockerImage = docker.build registry + ":$BUILD_NUMBER"
							}
						}
					}
					stage('Push Docker Image') {
						steps {
							script {
								docker.withRegistry( '', registryCredential ) {
									dockerImage.push()
								}
							}
							slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Docker Image Push Success ${env.JOB_NAME} ${env.BUILD_NUMBER}"
						}
					}		
					stage('Docker Running') {
						steps{
							sh 'docker run -d -p 8081:8080 -p 5432:5432 ${registry}":$BUILD_NUMBER"'
						}
					}						
					stage('Kubernetes Deploy') {
						steps{
							sh 'pwd'	
							sh "sed -i 's/tagversion/${env.BUILD_ID}/g' deployment.yaml"	
							step([$class: 'KubernetesEngineBuilder', 
								projectId: KubernetesProjectID,
								clusterName: KubernetesClusterName,
								zone: KubernetesZone,
								manifestPattern: 'deployment.yaml',
								credentialsId: KubernetesCredential,
								verifyDeployments: true])
						}
					}
				}
			}
			stage('Prod Server Deploy') {		
				steps{
					deploy adapters: [tomcat8(credentialsId: TomcatCredential, path: '', url: TestDeployURL)], contextPath: '/ProdWebapp', war: '**/*.war'	
					slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Deployed to Prod ${env.JOB_NAME} ${env.BUILD_NUMBER}"	    
					jiraComment body: "Deploy to Prod was successfull ${env.JOB_NAME} ${env.BUILD_NUMBER}", issueKey: JiraIssueKey
				}
				post {
					always { 
						jiraSendDeploymentInfo environmentId: 'Prod', environmentName: 'Production', serviceIds: [''], environmentType: 'production', site: JiraURL, state: 'successful'
						jiraTransitionIssue idOrKey: JiraIssueKey, input: [ transition: [ id: 31] ], site: JiraSiteForTransition
					}
				}
			}			
        	}
	}	
	    
	stage('Perform Sanity Test - Publish Report') {
		steps{
			script {
			     sh 'mvn -f Acceptancetest/pom.xml package'
			     sh 'mvn package test'
			     publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\Acceptancetest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'Sanity Test Report', reportTitles: ''])
			     slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Perform Sanity Test - Publish Report ${env.JOB_NAME} ${env.BUILD_NUMBER}"
			}
		}
	 }	 	    
    }
    post {
	success {
		echo 'All stages ran successfully'
		slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "All Stages ran successfully ${env.JOB_NAME} ${env.BUILD_NUMBER}"
	}
	failure {
		echo 'Failed in some stage'
		slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Failed in some stage ${env.JOB_NAME} ${env.BUILD_NUMBER}"
	}
    }
}
void ArtifactConfig() {
                rtServer (
                   id: rtServerID,
                   url: JfrogURL,
                   credentialsId: JfrogLogin
                )
		rtMavenResolver (
		    id: 'resolver-artifactory',
		    serverId: rtServerID,
		    releaseRepo: 'libs-release',
		    snapshotRepo: 'libs-snapshot'
		)  
		rtMavenDeployer (
		    id: 'deployer-artifactory',
		    serverId: rtServerID,
		    //deployArtifacts: false,
		    releaseRepo: 'libs-release-local',
		    snapshotRepo: 'libs-snapshot-local',
		    // By default, 3 threads are used to upload the artifacts to Artifactory. You can override this default by setting:
		    threads: 6
		)
}
	
void ArtifactRun() {
			rtMavenRun (
			    // Tool name from Jenkins configuration.
			    tool: 'maven',
			    pom: 'pom.xml',
			    //goals: 'clean install deploy -e -o',
			    //goals: 'clean install',
			    goals: 'clean install -e',
			    // Maven options.
			    //opts: '-Xms1024m -Xmx4096m',
			    //opts: '-Dartifactory.publish.artifacts=false -Dartifactory.publish.buildInfo=false',				
			    resolverId: 'resolver-artifactory',
			    deployerId: 'deployer-artifactory',
			    //opts: '-Dartifactory.publish.buildInfo=true'
			    // If the build name and build number are not set here, the current job name and number will be used:
			)
}
void StoreArtifact() {
			rtUpload (
			     serverId: rtServerID,
			      spec: """{
			                     "files": [
			                             {
			                                 "pattern": "target/*.war",
			                                 "target": "libs-release-local"
			                             }
			                         ]
			      		}"""
			      )			
			rtPublishBuildInfo (
			   serverId: rtServerID		
			)
}
