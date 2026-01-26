FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace

COPY pom.xml ./
COPY common/pom.xml common/pom.xml
COPY inventory-service/pom.xml inventory-service/pom.xml

RUN mvn -q -DskipTests -pl inventory-service -am dependency:go-offline

COPY common/src common/src
COPY inventory-service/src inventory-service/src

RUN mvn -q -pl inventory-service -am -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/inventory-service/target/*.jar /app/app.jar
EXPOSE 8084
ENTRYPOINT ["java","-jar","/app/app.jar"]
