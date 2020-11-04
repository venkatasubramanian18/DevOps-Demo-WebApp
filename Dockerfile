FROM tomcat:8-jre8
#FROM maven:latest

LABEL maintainer=”venkatasubramanian18@gmail.com”

#RUN mkdir -p /var/lib/tomcat8/webapps/
RUN ls -ltr 
RUN pwd 
#COPY pom.xml /var/lib/tomcat8/webapps/
#COPY /target/*.war /var/lib/tomcat8/webapps/
#COPY /target/*.war /var/lib/tomcat8/webapps/
COPY ./target/*.war /usr/local/tomcat/webapps/
RUN pwd 
#WORKDIR /usr/local/tomcat/webapps/

# build for release
#RUN mvn clean install -e

#EXPOSE 8000

#CMD [“catalina.sh”, “run”]
CMD ["/usr/local/tomcat/bin/catalina.sh","run"]
