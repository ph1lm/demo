FROM fabric8/java-jboss-openjdk8-jdk:1.2.3

ENV JAVA_APP_JAR demo-0.0.1-SNAPSHOT.jar
ENV AB_ENABLED off
ENV AB_JOLOKIA_AUTH_OPENSHIFT true

EXPOSE 8080

RUN chmod -R 777 /deployments/
ADD target/demo-0.0.1-SNAPSHOT.jar /deployments/
