#!/bin/sh
#usage: ./start_all_with_appdynamics.sh
#the startup scipt must be placed in the same folder than the spring petclinic microservice application
#the path to the inspectit installation folder and the waittime between the startup of the services
mvn clean install -DskipTests


cd spring-petclinic-config-server
echo "Starting Configuration Server"
mvn spring-boot:run &
cd ..

./wait-for-it.sh localhost:8888 --timeout=60

cd spring-petclinic-discovery-server
echo "Starting Discovery Server"
mvn spring-boot:run &
cd ..

./wait-for-it.sh localhost:8761 --timeout=60

xdg-open http://localhost:8761

cd spring-petclinic-customers-service
echo "Starting Customers Service"
mvn spring-boot:run -Drun.jvmArguments="-Dappdynamics.agent.tierName=CustomerService" &
cd ..

./wait-for-it.sh localhost:8761 --timeout=60

cd spring-petclinic-vets-service
echo "Starting Vets Service"
mvn spring-boot:run -Drun.jvmArguments="-Dappdynamics.agent.tierName=VetsService" &
cd ..

./wait-for-it.sh localhost:8761 --timeout=60

cd spring-petclinic-visits-service
echo "Starting Visits Service"
mvn spring-boot:run -Drun.jvmArguments="-Dappdynamics.agent.tierName=VisitsService" &
cd ..

./wait-for-it.sh localhost:8761 --timeout=60

cd spring-petclinic-api-gateway
echo "Starting API Gateway"
mvn spring-boot:run -Drun.jvmArguments="-Dappdynamics.agent.tierName=ApiGateway" &
cd ..

./wait-for-it.sh localhost:8761 --timeout=60

cd spring-petclinic-admin-server
echo "Starting Admin Server"
mvn spring-boot:run -Drun.jvmArguments="-Dappdynamics.agent.tierName=AdminServer" &
cd ..

./wait-for-it.sh localhost:8080 --timeout=240
xdg-open http://localhost:8080

echo "All Services started!"
