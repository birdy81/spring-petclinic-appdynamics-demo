@echo off

rem usage: Start_all_with_inspectIT.bat <agent_path>
rem the startup scipt must be placed in the same folder than the spring petclinic application
rem the path to the inspectit installation folder and the WAITTIME between the startup of the services
rem !!!!do not use spaces in the path of inspectIT installation folder!!!!

set AGENTDIR=%1
set WAITTIME=10
set /a "x = 0"

rem STARTTYPE, z.B. /B = start without open a new windows, /MIN start minized in new windows
set STARTTYPE=/B

if exist "%AGENTDIR%/inspectit-agent.jar" (
	echo "Agent jar found."
	cd spring-petclinic-config-server
	echo "Starting Configuration Server"
	start %STARTTYPE% mvn spring-boot:run
	cd ..
	
	:loop1
	set /a "x = x + 1"
	timeout /T 1 > nul
	netstat -a -o -n -proto TCP | findstr 8888
	if errorlevel 1 (if %x% leq 60 goto :loop1)
	set /a "x = 0"
	
	cd spring-petclinic-discovery-server
	echo "Starting Discovery Server"
	start %STARTTYPE% mvn spring-boot:run 
	cd ..
	
	:loop2
	set /a "x = x + 1"
	timeout /T 1 > nul
	netstat -a -o -n -proto TCP | findstr 8761
	if errorlevel 1 (if %x% leq 60 goto :loop2) else ( 
		timeout /T %WAITTIME% > nul 
		start "" http://localhost:8761 
	)
	
	set /a "x = 0"
		
	cd spring-petclinic-customers-service
	echo "Starting Customers Service"
	start %STARTTYPE% mvn spring-boot:run -Drun.jvmArguments="-javaagent:%AGENTDIR%/inspectit-agent.jar -Dinspectit.repository=localhost:9070 -Dinspectit.agent.name=customers-service" 
	cd ..
	timeout /T %WAITTIME% > nul
	cd spring-petclinic-vets-service
	echo "Starting Vets Service"
	start %STARTTYPE% mvn spring-boot:run -Drun.jvmArguments="-javaagent:%AGENTDIR%/inspectit-agent.jar -Dinspectit.repository=localhost:9070 -Dinspectit.agent.name=vets-service" 
	cd ..
	timeout /T %WAITTIME% > nul
	cd spring-petclinic-visits-service
	echo "Starting Visits Service"
	start %STARTTYPE% mvn spring-boot:run -Drun.jvmArguments="-javaagent:%AGENTDIR%/inspectit-agent.jar -Dinspectit.repository=localhost:9070 -Dinspectit.agent.name=visits-service" 
	cd ..
	timeout /T %WAITTIME% > nul
	cd spring-petclinic-api-gateway
	echo "Starting API Gateway"
	start %STARTTYPE% mvn spring-boot:run -Drun.jvmArguments="-javaagent:%AGENTDIR%/inspectit-agent.jar -Dinspectit.repository=localhost:9070 -Dinspectit.agent.name=api-gateway" 
	cd ..
	timeout /T %WAITTIME% > nul
	cd spring-petclinic-admin-server
	echo "Starting Admin Server"
	start %STARTTYPE% mvn spring-boot:run -Drun.jvmArguments="-javaagent:%AGENTDIR%/inspectit-agent.jar -Dinspectit.repository=localhost:9070 -Dinspectit.agent.name=admin-server" 
	cd ..
	
	:loop3
	set /a "x = x + 1"
	timeout /T 1 > nul
	netstat -a -o -n -proto TCP | findstr 8080
	if errorlevel 1 (if %x% leq 180 goto :loop3) else ( start "" http://localhost:8080 )
	set /a "x = 0"
	
	echo "All Services started!"
	
) else ( 
	echo Agent jar not found. Specify the path to the inspectIT agent
	echo Example: Start_all_with_inspectIT.bat c:/user/inspectIT/agent.
	echo In case you have not installed inspectIT go to https://github.com/inspectIT/inspectIT/releases
)