FROM java:8
VOLUME /tmp
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh wait-for-it.sh
RUN bash -c 'chmod +x wait-for-it.sh'
ARG ARTIFACT_NAME
ADD ${ARTIFACT_NAME}.jar /app.jar
ENV SPRING_PROFILES_ACTIVE docker
RUN bash -c 'touch /app.jar'
ENV INSPECTIT_VERSION 1.7.9.92
RUN wget --no-check-certificate https://github.com/inspectIT/inspectIT/releases/download/${INSPECTIT_VERSION}/inspectit-agent-java6-${INSPECTIT_VERSION}.zip \
&& unzip inspectit-agent-java6-${INSPECTIT_VERSION}.zip \
&& rm -f inspectit-agent-java6-${INSPECTIT_VERSION}.zip
EXPOSE 8081
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
