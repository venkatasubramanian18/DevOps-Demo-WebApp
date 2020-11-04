FROM tomcat:latest
#FROM maven:latest

LABEL maintainer=”venkatasubramanian18@gmail.com”

#RUN mkdir -p /var/lib/tomcat8/webapps/
RUN ls -ltr 
#COPY pom.xml /var/lib/tomcat8/webapps/
#COPY /target/*.war /var/lib/tomcat8/webapps\
COPY /var/lib/jenkins/workspace/devops-pipeline/target/AVNCommunication-1.0.war /var/lib/tomcat8/webapps/

#WORKDIR /usr/local/tomcat/webapps/

# build for release
#RUN mvn clean install -e

EXPOSE 8000

#CMD [“catalina.sh”, “run”]
