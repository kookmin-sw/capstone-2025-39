# 1. Java 23 기반 이미지 사용 (Temurin 기준)
FROM eclipse-temurin:23-jdk

# 2. JAR 파일을 복사
COPY build/libs/*.jar app.jar

# 3. 앱 실행
ENTRYPOINT ["java", "-jar", "/app.jar"]