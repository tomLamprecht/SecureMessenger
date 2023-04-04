FROM nginx

RUN apt-get update && apt-get upgrade -y

COPY build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]



FROM openjdk:17

VOLUME /backend

EXPOSE 8080

ARG JAR_FILE=target/rest-service-complete-0.0.1-SNAPSHOT.jar

ADD ${JAR_FILE} app.jar

ENTRYPOINT ["java","-jar","/app.jar"]