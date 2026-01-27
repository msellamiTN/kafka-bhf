FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY payment-service/pom.xml payment-service/
COPY common/pom.xml common/
COPY pom.xml .
COPY payment-service/src payment-service/src
COPY common/src common/src
RUN mvn -q -DskipTests -pl payment-service clean package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/payment-service/target/*.jar /app/app.jar
EXPOSE 8083
ENTRYPOINT ["java","-jar","/app/app.jar"]
