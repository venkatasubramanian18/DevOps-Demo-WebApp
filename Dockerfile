FROM tomcat:8-jre8

COPY ./AVNCommunication-1.0.war /usr/local/tomcat/webapps

CMD ["catalina.sh","run"]
