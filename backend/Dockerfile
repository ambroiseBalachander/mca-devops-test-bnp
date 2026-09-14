FROM cgr.dev/chainguard/maven:latest AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM cgr.dev/chainguard/jre:latest
WORKDIR /app
COPY --from=build /app/target/*.jar ./app.jar

ENV SPRING_PROFILES_ACTIVE=prod
EXPOSE 8080

USER 65532

ENTRYPOINT ["java", "-jar", "app.jar"]