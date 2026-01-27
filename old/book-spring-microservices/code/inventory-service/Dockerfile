FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY inventory-service/pom.xml inventory-service/
COPY common/pom.xml common/
COPY pom.xml .
COPY inventory-service/src inventory-service/src
COPY common/src common/src
RUN mvn -q -DskipTests -pl inventory-service clean package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/inventory-service/target/*.jar /app/app.jar
EXPOSE 8084
ENTRYPOINT ["java","-jar","/app/app.jar"]
