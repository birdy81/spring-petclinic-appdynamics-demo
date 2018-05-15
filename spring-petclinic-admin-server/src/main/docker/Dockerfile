FROM java:8
VOLUME /tmp
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh wait-for-it.sh
RUN bash -c 'chmod +x wait-for-it.sh'
ARG ARTIFACT_NAME
ADD ${ARTIFACT_NAME}.jar /app.jar
ENV SPRING_PROFILES_ACTIVE docker
RUN bash -c 'touch /app.jar'
COPY AppServerAgent-4.3.5.13.zip AppServerAgent-4.3.5.13.zip
RUN unzip AppServerAgent-4.3.5.13.zip -d AppServerAgent \
&& rm -f AppServerAgent-4.3.5.13.zip
EXPOSE 9090
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
