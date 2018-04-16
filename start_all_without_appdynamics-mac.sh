#!/bin/sh
#usage: ./start_all_with_appdynamics.sh
#the startup scipt must be placed in the same folder than the spring petclinic microservice application

cd spring-petclinic-config-server/target
echo "Starting Configuration Server"
java -jar spring-petclinic-config-server-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8888 --timeout=60

cd spring-petclinic-discovery-server/target
echo "Starting Discovery Server"
java -jar spring-petclinic-discovery-server-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8761 --timeout=60

open http://localhost:8761

cd spring-petclinic-customers-service/target
echo "Starting Customers Service"
java -jar spring-petclinic-customers-service-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8761 --timeout=60

cd spring-petclinic-vets-service/target
echo "Starting Vets Service"
java -jar spring-petclinic-vets-service-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8761 --timeout=60

cd spring-petclinic-visits-service/target
echo "Starting Visits Service"
java -jar spring-petclinic-visits-service-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8761 --timeout=60

cd spring-petclinic-api-gateway/target
echo "Starting API Gateway"
java -jar spring-petclinic-api-gateway-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8761 --timeout=60

cd spring-petclinic-admin-server/target
echo "Starting Admin Server"
java -jar spring-petclinic-admin-server-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8080 --timeout=240
open http://localhost:8080

echo "All Services started!"
