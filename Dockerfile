from tomcat:latest

RUN mkdir -p /jenkins/docker/webapp

COPY ./AVNCommunication-1.0.war /jenkins/docker/webapp/
