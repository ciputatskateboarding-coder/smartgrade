# 1. Tahap Build (Kompilasi Java)
FROM maven:3.8.8-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# 2. Tahap Runtime (Menjalankan Aplikasi)
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Hugging Face Spaces berjalan di port 7860 secara default
ENV PORT=7860
EXPOSE 7860

CMD ["java", "-jar", "app.jar"]