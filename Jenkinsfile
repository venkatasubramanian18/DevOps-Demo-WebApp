//Pipeline for full DEVOPS:
pipeline {
    environment {
	SONAR_CRED = credentials('sonaradmin')	
 	SONAR_URL_CRED = credentials('SonarURL')
	GITHUB_CRED = credentials('GithubURL')	
	JIRA_CRED = credentials('JiraURL')
	TS_CRED = credentials('TestDeployURL')
	PS_CRED = credentials('ProdDeployURL')
	JFROG_CRED = credentials('JfrogURL')
	DOCKER_REGISTRY_CRED = credentials('DockerRegistry')
	registryCredential = 'dockerhub'
	dockerImage = ''
	JfrogLogin = 'artifactory'
	rtServerID = 'artifactory'
	GitHubLogin = 'github'
	SlackChannel = '#devops'
	SlackToken = 'slacktoken'
	JiraIssueKey = 'DD-3'
	JiraSiteForTransition = 'jirasite'
	SonarCredential = 'sonar'	
	SonarInstallationName = 'sonarqube'
	TomcatCredential = 'tomcat'
	BlazemeterCredential = 'Blazemeter'
	KubernetesCredential = "k8saccount"
	KubernetesProjectID = 'devops-294021'
	KubernetesClusterName = 'k8scluster'
	KubernetesZone = "us-central1-c"
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
		sh 'docker container ls | grep "${DockerRegistry_CRED_USR}:*" | xargs -r docker stop' 
                git credentialsId: GitHubLogin, url: GITHUB_CRED_USR	
		slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Pipeline build Started ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            }
        }
	    
        stage('Code Analysis - SonarQube') {
		steps {
			withSonarQubeEnv(credentialsId: SonarCredential, installationName: SonarInstallationName) { 
				sh 'mvn clean package sonar:sonar -Dsonar.host.url=$SONAR_URL_CRED_USR -Dsonar.sources=. -Dsonar.tests=. -Dsonar.inclusions=**/test/java/servlet/createpage_junit.java -Dsonar.test.exclusions=**/test/java/servlet/createpage_junit.java -Dsonar.login=$SONAR_CRED_USR -Dsonar.password=$SONAR_CRED_PSW'
			}
			slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "SonarQube Analysis Succeed ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
		}
	}
	stage('Build - Maven') {
		steps {		
			sh 'mvn clean install'
			//ArtifactRun()
			jiraTransitionIssue idOrKey: JiraIssueKey, input: [ transition: [ id: 21] ], site: JiraSiteForTransition
			jiraSendBuildInfo branch: JiraIssueKey, site: JIRA_CRED_USR		
			slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Build Success ${env.JOB_NAME} ${env.BUILD_NUMBER}"
		}
 	} 
    	stage('Test Server Deploy') {
		steps{
			script {
				deploy adapters: [tomcat8(credentialsId: TomcatCredential, path: '', url: TS_CRED_USR)], contextPath: '/QAWebapp', war: '**/*.war'	
				slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Deployed to Test ${env.JOB_NAME} ${env.BUILD_NUMBER}"	
				jiraComment body: "Deploy to Test was successfull ${env.JOB_NAME} ${env.BUILD_NUMBER}", issueKey: JiraIssueKey				
			}

		}
		post {
			always { 
			jiraSendDeploymentInfo environmentId: 'Test', environmentName: 'Test', serviceIds: [''], environmentType: 'testing', site: JIRA_CRED_USR, state: 'successful'
			}
		}
   	}
	stage('Store Artifact') {
		steps{
			StoreArtifact()
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
	    
// 	stage('Performance Test - Blazemeter') {
//		steps{
//	   		blazeMeterTest credentialsId: BlazemeterCredential, testId: '8626535.taurus', workspaceId: '677291'
//	    		slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Performance Test - Blazemeter ${env.JOB_NAME} ${env.BUILD_NUMBER}"
//		}
//	}	  
//
	stage('Deploy to Production') {
		parallel{
		        stage('Docker & Kubernetes'){
				stages{
					stage('Build Docker Image') {
						steps {
							script {
								echo registry + ":$BUILD_NUMBER"
								sh 'pwd'
								dockerImage = docker.build DOCKER_REGISTRY_CRED + ":$BUILD_NUMBER"
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
					stage('Cleanup server space') {
						steps{
							echo 'clean'
							//sh "docker rmi ${registry}:${currentBuild.previousBuild.getNumber()}"
						}
					}											
					stage('Docker Running') {
						steps{
							sh 'docker run -d -p 8081:8080 -p 5432:5432 ${DockerRegistry_CRED_USR}":$BUILD_NUMBER"'
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
					deploy adapters: [tomcat8(credentialsId: TomcatCredential, path: '', url: PS_CRED_USR)], contextPath: '/ProdWebapp', war: '**/*.war'	
					slackSend channel: SlackChannel, tokenCredentialId: SlackToken, message: "Deployed to Prod ${env.JOB_NAME} ${env.BUILD_NUMBER}"	    
					jiraComment body: "Deploy to Prod was successfull ${env.JOB_NAME} ${env.BUILD_NUMBER}", issueKey: JiraIssueKey
				}
				post {
					always { 
						jiraSendDeploymentInfo environmentId: 'Prod', environmentName: 'Production', serviceIds: [''], environmentType: 'production', site: JIRA_CRED_USR, state: 'successful'
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
                   url: JFROG_CRED_USR,
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
