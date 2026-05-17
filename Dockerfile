# Gunakan base image Ubuntu Noble dengan Java 26 JDK resmi
FROM eclipse-temurin:26-jdk-noble

# Install Maven secara manual di dalam sistem
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Atur lingkungan kerja
WORKDIR /app

# Ambil dependensi proyek terlebih dahulu agar build cepat
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy seluruh source code
COPY src ./src

# Kompilasi langsung di lingkungan Java 26
RUN mvn clean package -DskipTests

# Pindahkan file .jar hasil build (Dilakukan saat masih menjadi ROOT agar tidak Permission Denied)
RUN cp target/*.jar app.jar

# SYARAT UTMAK HUGGING FACE: Ubah hak milik folder ke user 1000
RUN chown -R 1000:1000 /app

# Baru kita pindah ke user 1000 di paling bawah
USER 1000
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Setup Port Hugging Face
ENV PORT=7860
EXPOSE 7860

CMD ["java", "-jar", "app.jar", "--server.port=7860"]
