# Stage 1: Build
FROM gradle:8.5-jdk17 AS builder

WORKDIR /app

# 1. Gradle 설정 파일들 먼저 복사 (캐싱 효율을 위해)
COPY gradle/ gradle/
COPY gradlew .
COPY gradle.properties .
COPY settings.gradle .
COPY build.gradle .

# 2. gradlew 실행 권한 부여 (필수: 윈도우에서 넘어오면 깨지는 경우 방지)
RUN chmod +x gradlew

# 3. 소스 코드 복사
# (이 부분이 에러가 난다면 아래 '빌드 명령어' 섹션을 꼭 확인하세요)
COPY src/ src/

# 4. 애플리케이션 빌드 (테스트 제외)
# --no-daemon 옵션을 주면 빌드가 더 안정적입니다.
RUN ./gradlew build -x test --no-daemon

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# 5. 빌드 결과물 복사 (Quarkus Fast-jar 구조)
COPY --from=builder /app/build/quarkus-app/lib/ /app/lib/
COPY --from=builder /app/build/quarkus-app/*.jar /app/
COPY --from=builder /app/build/quarkus-app/app/ /app/app/
COPY --from=builder /app/build/quarkus-app/quarkus/ /app/quarkus/

# gRPC 포트 노출
EXPOSE 9000

# 실행 명령어
ENTRYPOINT ["java", "-jar", "/app/quarkus-run.jar"]