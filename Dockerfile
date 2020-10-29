FROM java:latest

# Install maven
#RUN apt-get -y update && apt-get install -y maven

WORKDIR /code

# Prepare by downloading dependencies
ADD pom.xml /code/pom.xml

# Adding source, compile and package into a fat jar
ADD src /code/src
RUN ["mvn", "package"]

EXPOSE 8080
CMD ["mvn", "tomcat7:run"]
