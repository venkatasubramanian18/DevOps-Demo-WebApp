from tomcat:latest

LABEL maintainer=”venkatasubramanian18@gmail.com”

RUN mkdir -p /jenkins/docker/webapp

COPY target/AVNCommunication-1.0.war /jenkins/docker/webapp/

EXPOSE 8000

CMD [“catalina.sh”, “run”]
