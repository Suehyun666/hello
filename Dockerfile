# Multi-stage build for Quarkus gRPC application

# Stage 1: Build
FROM gradle:8.5-jdk17 AS builder

WORKDIR /app

# Copy gradle files
COPY gradle gradle
COPY gradlew gradlew.bat gradle.properties settings.gradle build.gradle ./

# Copy source code
COPY src ./src

# Build the application
RUN ./gradlew build -x test

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy the built application from builder
COPY --from=builder /app/build/quarkus-app/lib/ /app/lib/
COPY --from=builder /app/build/quarkus-app/*.jar /app/
COPY --from=builder /app/build/quarkus-app/app/ /app/app/
COPY --from=builder /app/build/quarkus-app/quarkus/ /app/quarkus/

# Expose gRPC port (default Quarkus gRPC port)
EXPOSE 9000

# Run the application
ENTRYPOINT ["java", "-jar", "/app/quarkus-run.jar"]
