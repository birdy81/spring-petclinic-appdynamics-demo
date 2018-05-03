#!/bin/sh
#usage: ./start_all_with_appdynamics.sh
#the startup scipt must be placed in the same folder than the spring petclinic microservice application
#the path to the inspectit installation folder and the waittime between the startup of the services

mvn clean install -DskipTests

cd spring-petclinic-config-server/target
echo "Starting Configuration Server"
java -javaagent:../../put-appdynamics-agent-here/javaagent.jar -Dappdynamics.agent.tierName=ConfigurationService -Dappdynamics.agent.nodeName=ConfigurationServiceNode -jar spring-petclinic-config-server-1.5.1.jar &
cd ../..

./wait-for-it.sh localhost:8888 --timeout=60

cd spring-petclinic-discovery-server/target
echo "Starting Discovery Server"
java -javaagent:../../put-appdynamics-agent-here/javaagent.jar -Dappdynamics.agent.tierName=DiscoveryServer -Dappdynamics.agent.nodeName=DiscoveryServerNode -jar spring-petclinic-discovery-server-1.5.1.jar &
cd ../..

./wait-for-it.sh localhost:8761 --timeout=60

xdg-open http://localhost:8761
cd spring-petclinic-customers-service/target
echo "Starting Customers Service"
java -javaagent:../../put-appdynamics-agent-here/javaagent.jar -Dappdynamics.agent.tierName=CustomerService -Dappdynamics.agent.nodeName=CustomerServiceNode -jar spring-petclinic-customers-service-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8761 --timeout=60

cd spring-petclinic-vets-service/target
echo "Starting Vets Service"
java -javaagent:../../put-appdynamics-agent-here/javaagent.jar -Dappdynamics.agent.tierName=VetsService -Dappdynamics.agent.nodeName=VetsServiceNode -jar spring-petclinic-vets-service-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8761 --timeout=60

cd spring-petclinic-visits-service/target
echo "Starting Visits Service"
java -javaagent:../../put-appdynamics-agent-here/javaagent.jar -Dappdynamics.agent.tierName=VisitsService -Dappdynamics.agent.nodeName=VisitsServiceNode -jar spring-petclinic-visits-service-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8761 --timeout=60

cd spring-petclinic-api-gateway/target
echo "Starting API Gateway"
java -javaagent:../../put-appdynamics-agent-here/javaagent.jar -Dappdynamics.agent.tierName=ApiGateway -Dappdynamics.agent.nodeName=ApiGatewayNode -jar spring-petclinic-api-gateway-1.5.1.jar &
cd ../..

./wait-for-it-mac.sh localhost:8761 --timeout=60

cd spring-petclinic-admin-server/target
echo "Starting Admin Server"
java -javaagent:../../put-appdynamics-agent-here/javaagent.jar -Dappdynamics.agent.tierName=AdminServer -Dappdynamics.agent.nodeName=AdminServerNode -jar spring-petclinic-admin-server-1.5.1.jar &
cd ../..

./wait-for-it.sh localhost:8080 --timeout=240
xdg-open http://localhost:8080

echo "All Services started!"
