FROM cgr.dev/chainguard/maven:latest AS build
WORKDIR /app

# 1. Copier d'abord uniquement le pom.xml pour télécharger les dépendances (mise en cache des layers Docker)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 2. Copier le reste du code source et compiler
COPY src ./src
RUN mvn package -DskipTests -B

FROM cgr.dev/chainguard/jre:latest
WORKDIR /app
COPY --from=build /app/target/*.jar ./app.jar

ENV SPRING_PROFILES_ACTIVE=prod
EXPOSE 8080

USER 65532

ENTRYPOINT ["java", "-jar", "app.jar"]