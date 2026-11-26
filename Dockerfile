# --- Étape 1 : Compilation, tests et packaging WAR (JDK 21 + Gradle) ---
FROM eclipse-temurin:21-jdk AS builder

WORKDIR /app

COPY gradlew .
COPY gradle gradle
COPY build.gradle* settings.gradle* ./

RUN sed -i 's/\r$//' gradlew \
    && chmod +x gradlew \
    && ./gradlew dependencies --no-daemon

COPY src src
RUN ./gradlew clean test bootWar --no-daemon

# --- Étape 2 : Exécution sur Tomcat 10.1.24 + Eclipse Temurin JRE ---

FROM tomcat:10.1.24-jre21
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/build/libs/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh","run"]
