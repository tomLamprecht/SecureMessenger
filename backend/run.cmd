mvn install
docker build -d backend .
docker run -p 8080:8080 -d backend