# Use an image that supports Java 21
FROM alpine:latest as packager

# Install Java 21 (make sure to check the package name and availability)
RUN apk --no-cache add openjdk21 openjdk21-jmods

ENV JAVA_MINIMAL="/opt/java-minimal"

# Build minimal JRE with Java 21
RUN /usr/lib/jvm/java-21-openjdk/bin/jlink \
    --verbose \
    --add-modules \
        java.base,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument \
    --compress 2 --strip-debug --no-header-files --no-man-pages \
    --release-info="add:IMPLEMENTOR=radistao:IMPLEMENTOR_VERSION=radistao_JRE" \
    --output "$JAVA_MINIMAL"

FROM alpine:latest

ENV JAVA_HOME=/opt/java-minimal
ENV PATH="$PATH:$JAVA_HOME/bin"

COPY --from=packager "$JAVA_HOME" "$JAVA_HOME"

# Use an image with Maven and Java 21
FROM maven:3.6.0-jdk-21-slim AS build
COPY src /home/app/src
COPY pom.xml /home/app
RUN mvn -f /home/app/pom.xml clean package

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/home/app/target/demo-0.0.1-SNAPSHOT.jar"]
