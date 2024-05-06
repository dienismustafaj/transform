# Use a base image that supports Java 21
FROM adoptopenjdk/openjdk21:jdk-21.0.0_1-alpine as packager

ENV JAVA_MINIMAL="/opt/java-minimal"

# Build minimal JRE with Java 21
RUN jlink \
    --verbose \
    --add-modules \
        java.base,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument \
    --compress 2 --strip-debug --no-header-files --no-man-pages \
    --release-info="add:IMPLEMENTOR=radistao:IMPLEMENTOR_VERSION=radistao_JRE" \
    --output "$JAVA_MINIMAL"

# Use a fresh Alpine image for the runtime
FROM adoptopenjdk/openjdk21:jre-21.0.0_1-alpine

ENV JAVA_HOME=/opt/java-minimal
ENV PATH="$PATH:$JAVA_HOME/bin"

# Copy the minimal JRE from the previous stage
COPY --from=packager "$JAVA_HOME" "$JAVA_HOME"

# Set up Maven build stage
FROM maven:3.6.0-openjdk-11-slim AS build

# Copy Maven project files
COPY src /home/app/src
COPY pom.xml /home/app

# Build the Maven project
RUN mvn -f /home/app/pom.xml clean package

# Final image for runtime
FROM adoptopenjdk/openjdk11:jre-11.0.12_7-alpine

# Set Java environment variables
ENV JAVA_HOME=/opt/java-minimal
ENV PATH="$PATH:$JAVA_HOME/bin"

# Copy built JAR file from the build stage
COPY --from=build /home/app/target/demo-0.0.1-SNAPSHOT.jar /home/app/target/demo-0.0.1-SNAPSHOT.jar

# Expose port 8080
EXPOSE 8080

# Set the entry point for running the application
ENTRYPOINT ["java", "-jar", "/home/app/target/demo-0.0.1-SNAPSHOT.jar"]
