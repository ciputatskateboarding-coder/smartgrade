# 1. Tahap Build (Menggunakan Maven dengan Java 26)
FROM maven:3.9.9-eclipse-temurin-26 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# 2. Tahap Runtime (Menjalankan dengan Java 26)
FROM eclipse-temurin:26-jre-noble

# Buat user non-root khusus untuk keamanan Hugging Face
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

WORKDIR /app

# Copy hasil build dari tahap 1
COPY --from=build --chown=user:user /app/target/*.jar app.jar

# Hugging Face secara default membaca port 7860
ENV PORT=7860
EXPOSE 7860

CMD ["java", "-jar", "app.jar", "--server.port=7860"]
