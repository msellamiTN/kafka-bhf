FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY api-gateway/pom.xml api-gateway/
COPY common/pom.xml common/
COPY pom.xml .
COPY api-gateway/src api-gateway/src
COPY common/src common/src
RUN mvn -q -DskipTests -pl api-gateway clean package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/api-gateway/target/*.jar /app/app.jar
EXPOSE 8081
ENTRYPOINT ["java","-jar","/app/app.jar"]
