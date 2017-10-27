#!/bin/sh
#usage: ./start_all_with_inspectIT.sh <path to inspectIT agent> <CMR host>
#the startup scipt must be placed in the same folder than the spring petclinic microservice application
#the path to the inspectit installation folder and the waittime between the startup of the services
#!!!!do not use spaces in the path of the inspectIT installation folder!!!!

if [ "$#" -le 1 ]; then
  echo "Please specify the path to the inspectIT agent"
  exit 1
fi
if [ "$#" -ne 2 ]; then
  CMR_HOST="localhost"
else
  CMR_HOST="$2"
fi

AGENTDIR="$1"

if [ -e "$AGENTDIR/inspectit-agent.jar" ]
then

	echo "Agent jar found."

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
	mvn spring-boot:run -Drun.jvmArguments="-javaagent:${AGENTDIR}/inspectit-agent.jar -Dinspectit.repository=${CMR_HOST}:9070 -Dinspectit.agent.name=customers-service" &
	cd ..

	./wait-for-it.sh localhost:8761 --timeout=60

	cd spring-petclinic-vets-service
	echo "Starting Vets Service"
	mvn spring-boot:run -Drun.jvmArguments="-javaagent:${AGENTDIR}/inspectit-agent.jar -Dinspectit.repository=${CMR_HOST}:9070 -Dinspectit.agent.name=vets-service" &
	cd ..

	./wait-for-it.sh localhost:8761 --timeout=60

	cd spring-petclinic-visits-service
	echo "Starting Visits Service"
	mvn spring-boot:run -Drun.jvmArguments="-javaagent:${AGENTDIR}/inspectit-agent.jar -Dinspectit.repository=${CMR_HOST}:9070 -Dinspectit.agent.name=visits-service" &
	cd ..

	./wait-for-it.sh localhost:8761 --timeout=60

	cd spring-petclinic-api-gateway
	echo "Starting API Gateway"
	mvn spring-boot:run -Drun.jvmArguments="-javaagent:${AGENTDIR}/inspectit-agent.jar -Dinspectit.repository=${CMR_HOST}:9070 -Dinspectit.agent.name=api-gateway" &
	cd ..

	./wait-for-it.sh localhost:8761 --timeout=60

	cd spring-petclinic-admin-server
	echo "Starting Admin Server"
	mvn spring-boot:run -Drun.jvmArguments="-javaagent:${AGENTDIR}/inspectit-agent.jar -Dinspectit.repository=${CMR_HOST}:9070 -Dinspectit.agent.name=admin-server" &
	cd ..

	./wait-for-it.sh localhost:8080 --timeout=240
	xdg-open http://localhost:8080

	echo "All Services started!"

else
  echo Agent jar not found. Specify the path to the inspectIT agent
  echo Example: ./start_all_with_inspectIT.sh /home/user/inspectIT/agent
  echo Optionally you can also specify the CMR_HOST as second arugment
  echo Example: ./start_all_with_inspectIT.sh /home/user/inspectIT/agent localhost
  echo In case you have not installed inspectIT go to https://github.com/inspectIT/inspectIT/releases
fi
