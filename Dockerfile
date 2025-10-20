# 使用官方 OpenJDK 运行环境
FROM openjdk:17-jdk-slim

# 设置工作目录
WORKDIR /app

# 复制 Maven 打包后的 jar 文件到容器
COPY target/*.jar app.jar

# 暴露端口（Spring Boot 默认8080）
EXPOSE 8080

# 启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]
