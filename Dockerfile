from tomcat:8.0.20-jre8

RUN mkdir /var/lib/jenkins/workspace/docker/webapp

COPY /var/lib/jenkins/workspace/docker/target/AVNCommunication-1.0.war /var/lib/jenkins/workspace/docker/webapp/
