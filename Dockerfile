FROM ajit5144/ubuntu-tcat-x2-1

RUN ls -ltr 
RUN pwd 

COPY /target/*.war /usr/local/tomcat/webapps
RUN pwd 

CMD ["/usr/local/tomcat/bin/catalina.sh","start"]
