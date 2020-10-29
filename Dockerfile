from tomcat:latest

RUN mkdir -p /jenkins/docker/webapp

COPY var/lib/jenkins/workspace/docker/target/AVNCommunication-1.0.war /jenkins/docker/webapp/
