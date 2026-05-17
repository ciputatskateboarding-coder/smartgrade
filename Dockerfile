# 1. Tahap Build (Menggunakan Maven dengan Java 26)
FROM maven:3.9.9-eclipse-temurin-26 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# 2. Tahap Runtime (Menjalankan dengan Java 26)
FROM eclipse-temurin:26-jre-noble
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

ENV PORT=10000
EXPOSE 10000

CMD ["java", "-jar", "app.jar"]