from tomcat:latest

LABEL maintainer=”venkatasubramanian18@gmail.com”

RUN mkdir -p /usr/local/tomcat/webapps/

COPY target/AVNCommunication-1.0.war /usr/local/tomcat/webapps/

EXPOSE 8000

#CMD [“catalina.sh”, “run”]
