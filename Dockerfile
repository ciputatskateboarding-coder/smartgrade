# 1. Tahap Build (Menggunakan Maven berbasis Java 21 yang dijamin ada di server)
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# 2. Tahap Runtime (Tetap dijalankan menggunakan Java 26 sesuai kebutuhan kodemu)
FROM eclipse-temurin:26-jre-noble

# Buat user non-root khusus untuk keamanan Hugging Face
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

WORKDIR /app

# Copy hasil build .jar dari tahap 1 ke tahap 2
COPY --from=build --chown=user:user /app/target/*.jar app.jar

# Port default Hugging Face
ENV PORT=7860
EXPOSE 7860

CMD ["java", "-jar", "app.jar", "--server.port=7860"]
