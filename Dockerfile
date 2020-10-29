from tomcat:latest
FROM maven:latest

LABEL maintainer=”venkatasubramanian18@gmail.com”

RUN mkdir -p /usr/local/tomcat/webapps/

COPY pom.xml /usr/local/tomcat/webapps/
COPY target/AVNCommunication-1.0.war /usr/local/tomcat/webapps/

WORKDIR /usr/local/tomcat/webapps/

# build for release
RUN mvn package

EXPOSE 8000

#CMD [“catalina.sh”, “run”]
