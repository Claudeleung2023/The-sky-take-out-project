# 使用 Maven 构建阶段
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
# 复制根目录的pom.xml
COPY pom.xml .
# 复制各个模块的源码和pom文件
COPY sky-common ./sky-common
COPY sky-pojo ./sky-pojo
COPY sky-server ./sky-server
# 构建项目
RUN mvn clean package -DskipTests

# 第二阶段：运行 jar 包
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY --from=build /app/sky-server/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
