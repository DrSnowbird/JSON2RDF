#FROM maven:3.6.0-jdk-8
FROM openkbs/jdk-mvn-py3

ENV APP_HOME=${HOME}/app
RUN mkdir -p ${APP_HOME}

LABEL maintainer="DrSnowbird@openkbs.org"

COPY ./app ${APP_HOME}

RUN sudo chown -R $USER:$USER ${APP_HOME} && ls -al ${APP_HOME}

# ---- build 
WORKDIR ${APP_HOME}
USER $USER

RUN mvn clean package

### entrypoint
ENTRYPOINT ["java", "-jar", "target/json2rdf-1.0.1-jar-with-dependencies.jar"]
