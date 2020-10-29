# Pull tomcat latest image from dockerhub 
From tomcat:latest

# copy war file on to container 
COPY ./var/lib/jenkins/workspace/devops-pipeline/target/AVNCommunication-1.0.war /usr/local/devops-pipeline/
