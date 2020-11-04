FROM tomcat:8-jre8

RUN ls -ltr 
RUN pwd
COPY /target/*.war /usr/local/tomcat/webapps/

CMD ["/usr/local/tomcat/bin/catalina.sh","run"]
