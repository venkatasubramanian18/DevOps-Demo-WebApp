FROM ajit5144/ubuntu-tcat-x2-1

RUN ls -ltr 
RUN pwd 

COPY ./target/*.war /usr/local/tomcat/webapps
RUN pwd 

EXPOSE 8080

CMD ["/usr/local/tomcat/bin/catalina.sh","run"]
