FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY order-service/pom.xml order-service/
COPY common/pom.xml common/
COPY pom.xml .
COPY order-service/src order-service/src
COPY common/src common/src
RUN mvn -q -DskipTests -pl order-service clean package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/order-service/target/*.jar /app/app.jar
EXPOSE 8082
ENTRYPOINT ["java","-jar","/app/app.jar"]
