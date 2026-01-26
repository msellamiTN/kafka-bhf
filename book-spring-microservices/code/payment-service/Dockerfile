FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace

COPY pom.xml ./
COPY common/pom.xml common/pom.xml
COPY payment-service/pom.xml payment-service/pom.xml

RUN mvn -q -DskipTests -pl payment-service -am dependency:go-offline

COPY common/src common/src
COPY payment-service/src payment-service/src

RUN mvn -q -pl payment-service -am -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/payment-service/target/*.jar /app/app.jar
EXPOSE 8083
ENTRYPOINT ["java","-jar","/app/app.jar"]
