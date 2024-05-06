# Base image with Java 21
FROM openjdk:21-slim AS java-base

# Install Maven
RUN apt-get update && apt-get install -y maven

# Use the custom image for the build stage
FROM java-base AS build

COPY src /home/app/src
COPY pom.xml /home/app
RUN mvn -f /home/app/pom.xml clean package

# Final stage
FROM openjdk:21-slim
COPY --from=build /home/app/target/web-0.0.1-SNAPSHOT.jar /home/app/web.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/home/app/web.jar"]
