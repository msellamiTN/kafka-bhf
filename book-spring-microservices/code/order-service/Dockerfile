FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace

COPY pom.xml ./
COPY common/pom.xml common/pom.xml
COPY order-service/pom.xml order-service/pom.xml

RUN mvn -q -DskipTests -pl order-service -am dependency:go-offline

COPY common/src common/src
COPY order-service/src order-service/src

RUN mvn -q -pl order-service -am -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/order-service/target/*.jar /app/app.jar
EXPOSE 8082
ENTRYPOINT ["java","-jar","/app/app.jar"]
