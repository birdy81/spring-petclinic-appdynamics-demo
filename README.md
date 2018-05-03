# Small extension to make the awesome PetClinic a small sample application for AppDynamics

[![Build Status](https://travis-ci.org/spring-petclinic/spring-petclinic-appdynamics-demo.svg?branch=master)](https://travis-ci.org/spring-petclinic/spring-petclinic-microservices/) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This microservices branch was initially derived from [AngularJS version](https://github.com/spring-petclinic/spring-petclinic-angular1) to demonstrate how to split sample Spring application into [microservices](http://www.martinfowler.com/articles/microservices.html). To achieve that goal we used [Spring Cloud Netflix](https://github.com/spring-cloud/spring-cloud-netflix) technology stack.

## Starting services locally without Docker
Every microservice is a Spring Boot application and can be started locally using IDE or `mvn spring-boot:run` command. Please note that supporting services (Config and Discovery Server) must be started before any other application (Customers, Vets, Visits and API).
Tracing server and Admin server startup is optional.
If everything goes well, you can access the following services at given location:
* Discovery Server - http://localhost:8761
* Config Server - http://localhost:8888
* AngularJS frontend (API Gateway) - http://localhost:8080
* Customers, Vets and Visits Services - random port, check Eureka Dashboard
* Admin Server (Spring Boot Admin) - http://localhost:9090

You can tell Config Server to use your local Git repository by using `local` Spring profile and setting
`GIT_REPO` environment variable, for example:
`-Dspring.profiles.active=local -DGIT_REPO=/projects/spring-petclinic-microservices-config`
### Start script
All services including the AppDynamics Java Agent can be started with a start script:
#### Windows
Open a CMD and execute the script:
`start_all_with_appdynamics.bat`.
The services can be stopped by closing the CMD.

#### Linux
Open a Terminal and execute the script:
`start_all_with_appdynamics.sh`.

The services can be stopped by executing the following script:
`stop_all.sh`

#### macOS
The macOS users need to first perform following commands (see https://github.com/vishnubob/wait-for-it/issues/15) in order to solve the problem of missing `timeout` function on their OS:
```
brew install coreutils
alias timeout=gtimeout
```

Please also use the customized startup scripts for Mac.


## Starting services locally with docker-compose
In order to start entire infrastructure using Docker, you have to build images by executing `mvn clean install -PbuildDocker`
from a project root. Once images are ready, you can start them with a single command
`docker-compose up`. Containers startup order is coordinated with [`wait-for-it.sh` script](https://github.com/vishnubob/wait-for-it).
After starting services it takes a while for API Gateway to be in sync with service registry,
so don't be scared of initial Zuul timeouts. You can track services availability using Eureka dashboard
available by default at http://localhost:8761.

## JMeter load test
A JMX JMeter file for the Petclinic can be found inside the jmeter directory and is called `pet_clinic_load_test.jmx`. The JMX file can be parameterized with the following parameters and their default values inside the brackets:

* `JHOST` - The host of the system under test (localhost)
* `JPORT` - The port of the system under test (8080)
* `JUSERS` - The number of users (3)
* `JRAMPUP` - The rampup time in seconds (10)
* `JINFLUXDB_HOST` - The influx database host (localhost)
* `JLOOPCOUNT` - The number of iterations (30)
* `JDURATION` - The duration of the test in seconds (100)
* `JDELAY` - The delay of the thread creation in seconds (10000)

To start a JMeter load test use the following command:

`jmeter -t jmx_file -n -JHOST="localhost" -JPORT="8080" -JUSERS=3`


## Understanding the Spring Petclinic application with a few diagrams
<a href="https://speakerdeck.com/michaelisvy/spring-petclinic-sample-application">See the presentation here</a>

You can then access petclinic here: http://localhost:8080/

<img width="782" alt="springboot-petclinic" src="https://cloud.githubusercontent.com/assets/838318/19653851/61c1986a-9a16-11e6-8b94-03fd7f775bb3.png">

## In case you find a bug/suggested improvement for Spring Petclinic Microservices

Our issue tracker is available here: https://github.com/spring-petclinic/spring-petclinic-microservices/issues

## AppDynamics configuration

This project comes with a sample configuration exported from AppDynamics 4.3.8 (PetStore_AppDynamics_Application.xml)

### Enable HSQLDB monitoring
The default sample runs on HSQLDB, which is often not recognized by AppDynamics out of the box. In order to add the
monitoring you need to add node specific configurations:

```
jdbc-callable-statements=org.hsqldb.jdbc.JDBCCallableStatement
jdbc-connections=org.hsqldb.jdbc.JDBCConnection
jdbc-prepared-statements=org.hsqldb.jdbc.JDBCPreparedStatement
jdbc-statements=org.hsqldb.jdbc.JDBCStatement
```

## Request and potential business transactions

Operation | Request | Method | AppDynamics BT matching
--- | ---  | --- | ---
Home | / | | URL equals /
List Owners | /api/customer/owners | GET | URL equals and type equals
Register Owner | /api/customer/owners | POST | URL equals and type equals
Select Owner / Edit Owner Screen | /api/gateway/owners/{id} or /api/customer/owners/{id} or /owners/{id} | GET | URL regex (/api/gateway\|customer/owners/\d*\|/owners/\d*), method equals
Edit Owner | /api/customer/owners/{id} | PUT | URL regex /api/gateway/owners/\d*, method equals
Show All Pets of Owner | api/customer/owners/{id}/pets | GET | URL regex /api/gateway/owners/\d*/pets, method equals
Select Pet Of Owner | /api/customer/owners/{id}/pets/{pet-id}| GET | URL regex /api/gateway/owners/\d*/pets/\d*, method equals
Edit Pet Of Owner | /api/customer/owners/{id}/pets/{pet-id} | PUT | URL regex /api/gateway/owners/\d*/pets/\d*, method equals
Add Pet to Owner | /api/customer/owners/{id}/pets | POST | URL regex /api/gateway/owners/\d*/pets, method equals
Show Visits | /api/visit/owners/{id}/pets/{pet-id}/visits | GET | URL regex /api/gateway/owners/\d*/pets/\d*/visits, method equals
Add Visit | /api/visit/owners/{id}/pets/{pet-id}/visits | POST | URL regex /api/gateway/owners/\d*/pets/\d*/visits, method equals
Show Vets | /api/vet/vets | GET | URL equals and type equals
Get Pet Types | /api/customer/petTypes | GET | URL equals and type equals

Part / Section | Identification
--- | ---
Templates | contains template.html
Status Update | Method invocation on de.codecentric.boot.admin.registry.StatusUpdater.updateStatusForAllApplications()
Health Check | /health
Scripts | starts with /scripts

## Service Endpoints
Basically just changing the ootb configuration to only use the first part
of the URI is enough to have a good first start.

## Information points
For demonstration sake this example includes some information points as well.
The idea is that for every pet type that is saved a unique information
point is created.

Pets are saved in the class org.springframework.samples.petclinic.customers.web.PetResource in the method save. The save method takes as second parameter an instance of PetRequest, which provides a getTypeId() method returning the pet type
There are six different pets: Cat (1), Dog (2), Lizard (3), Snake (4), Bird (5), Hamster (6)

## Local execution

This example can run locally. If it does not, please check the following:

#### Configuration Service accesses the internet
The default configuration service (ConfigServer) gets the configurations from the internet. The setting is done at
```
spring-petclinic-appdynamics-demo/spring-petclinic-config-server/src/main/resources/bootstrap.yml
```

Note that a local configuration can be given. By default the local configuration expects that the
configuration repository resides in your users home folder, but you can easily change that in the file.

You can tell Config Server to use your local Git repository by using local Spring profile and setting GIT_REPO environment variable, for example: -Dspring.profiles.active=local -DGIT_REPO=/projects/spring-petclinic-microservices-config

This example also provides a startup script that sets the spring.profiles to local

#### DNS resolution
Sometimes (at least on Macs) the local name resolution of the services cannot be performed as they use the host name, which is not
necessarily mapped to the loopback device. You can easily check this by navigating to the Eureka server and checking if you can
reach the services:

```
http://localhost:8761/
```

If you cannot reach a registered service, note the logical it is invoked with and simply add an entry to your hosts file (/etc/hosts).
If you are on Mac you can flush your DNS cache:

```
sudo /usr/bin/dscacheutil -flushcache
```


## Performance "problems"
This extension includes some very simple performance problems on purpose to visualize how APM tools can
detect these and show them to the user.

- Creating a new pet with the type Snake will impose a 1s delay. This is interesting if you have a look at the defined information points.
- Finding a customer with a customer ID that can be divided by 11 wil impose a 1s delay. The base setup only created 10 users, so these will all be fast.
- Vets have a performance problem that is increasing with load. A wait within synchronized block simulates synchronized work. With higher
  loads on the service, the problem will heavily increase. To showcase this problem there is a specialized load test
  available that heavily accesses the vets page.

## Intellij setup

- Please make sure to install the Lombok Plugin

## Database configuration

In its default configuration, Petclinic uses an in-memory database (HSQLDB) which
gets populated at startup with data. A similar setup is provided for MySql in case a persistent database configuration is needed.
Note that whenever the database type is changed, the data-access.properties file needs to be updated and the mysql-connector-java artifact from the pom.xml needs to be uncommented.

You may start a MySql database with docker:

```
docker run -e MYSQL_ROOT_PASSWORD=petclinic -e MYSQL_DATABASE=petclinic -p 3306:3306 mysql:5.7.8
```

## Looking for something in particular?

| Spring Cloud components | Resources  |
|-------------------------|------------|
| Configuration server    | [Config server properties](spring-petclinic-config-server/src/main/resources/application.yml) and [Configuration repository](https://github.com/spring-petclinic/spring-petclinic-microservices-config) |
| Service Discovery       | [Eureka server](spring-petclinic-discovery-server) and [Service discovery client](spring-petclinic-vets-service/src/main/java/org/springframework/samples/petclinic/vets/VetsServiceApplication.java) |
| API Gateway             | [Zuul reverse proxy](spring-petclinic-api-gateway/src/main/java/org/springframework/samples/petclinic/api/ApiGatewayApplication.java) and [Routing configuration](https://github.com/spring-petclinic/spring-petclinic-microservices-config/blob/master/api-gateway.yml) |
| Docker Compose          | [Spring Boot with Docker guide](https://spring.io/guides/gs/spring-boot-docker/) and [docker-compose file](docker-compose.yml) |
| Circuit Breaker         | TBD |
| Graphite Monitoring     | TBD |

 Front-end module  | Files |
|-------------------|-------|
| Node and NPM      | [The frontend-maven-plugin plugin downloads/installs Node and NPM locally then runs Bower and Gulp](spring-petclinic-ui/pom.xml)  |
| Bower             | [JavaScript libraries are defined by the manifest file bower.json](spring-petclinic-ui/bower.json)  |
| Gulp              | [Tasks automated by Gulp: minify CSS and JS, generate CSS from LESS, copy other static resources](spring-petclinic-ui/gulpfile.js)  |
| Angular JS        | [app.js, controllers and templates](spring-petclinic-ui/src/scripts/)  |



# Contributing

The [issue tracker](https://github.com/spring-petclinic/spring-petclinic-appdynamics-demo/issues) is the preferred channel for bug reports, features requests and submitting pull requests.

For pull requests, editor preferences are available in the [editor config](.editorconfig) for easy use in common text editors. Read more and download plugins at <http://editorconfig.org>.
