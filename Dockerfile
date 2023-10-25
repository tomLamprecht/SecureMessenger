FROM maven:3.9.4-amazoncorretto-17 AS backend_build
RUN mkdir -p /workspace
WORKDIR /workspace
COPY backend/pom.xml /workspace
RUN mvn -f pom.xml verify --fail-never
COPY backend/src /workspace/src
RUN mvn -f pom.xml clean package -DskipTests

FROM openjdk:17
COPY --from=backend_build /workspace/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]