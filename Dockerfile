from tomcat:latest

RUN mkdir -p /jenkins/docker/webapp

COPY target/AVNCommunication-1.0.war /jenkins/docker/webapp/

EXPOSE 8000
