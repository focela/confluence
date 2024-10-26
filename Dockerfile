# Base image
FROM openjdk:11-bullseye
LABEL maintainer="Son Tran Thanh <286.trants@gmail.com>"

ARG ATLASSIAN_PRODUCT=confluence
ARG APP_NAME=confluence
ARG APP_VERSION=8.5.16
ARG AGENT_VERSION=1.3.3
ARG MYSQL_DRIVER_VERSION=8.0.22

ENV CONFLUENCE_USER=confluence \
    CONFLUENCE_GROUP=confluence \
    CONFLUENCE_HOME=/var/confluence \
    CONFLUENCE_INSTALL=/opt/confluence \
    JVM_MINIMUM_MEMORY=4g \
    JVM_MAXIMUM_MEMORY=16g \
    JVM_CODE_CACHE_ARGS="-XX:InitialCodeCacheSize=2g -XX:ReservedCodeCacheSize=4g" \
    AGENT_PATH=/var/agent \
    AGENT_FILENAME=atlassian-agent.jar \
    LIB_PATH=/WEB-INF/lib \
    JAVA_OPTS="-javaagent:${AGENT_PATH}/${AGENT_FILENAME} ${JAVA_OPTS}"

RUN mkdir -p ${CONFLUENCE_INSTALL} ${CONFLUENCE_HOME} ${AGENT_PATH} ${CONFLUENCE_INSTALL}${LIB_PATH} \
    && curl -fsSL -o ${AGENT_PATH}/${AGENT_FILENAME} https://github.com/focela/confluence/releases/download/v${AGENT_VERSION}/atlassian-agent.jar \
    && curl -fsSL -o /tmp/atlassian.tar.gz https://product-downloads.atlassian.com/software/confluence/downloads/atlassian-${APP_NAME}-${APP_VERSION}.tar.gz \
    && tar -xzf /tmp/atlassian.tar.gz -C ${CONFLUENCE_INSTALL} --strip-components=1 \
    && rm /tmp/atlassian.tar.gz \
    && curl -fsSL -o ${CONFLUENCE_INSTALL}${LIB_PATH}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar \
    && echo "confluence.home=${CONFLUENCE_HOME}" > ${CONFLUENCE_INSTALL}/${ATLASSIAN_PRODUCT}/WEB-INF/classes/confluence-init.properties

RUN groupadd -r ${CONFLUENCE_GROUP} && useradd -r -g ${CONFLUENCE_GROUP} ${CONFLUENCE_USER} \
    && chown -R ${CONFLUENCE_USER}:${CONFLUENCE_GROUP} ${CONFLUENCE_INSTALL} ${CONFLUENCE_HOME} ${AGENT_PATH}

WORKDIR ${CONFLUENCE_INSTALL}
EXPOSE 8090

USER ${CONFLUENCE_USER}
ENTRYPOINT ["/opt/confluence/bin/start-confluence.sh", "-fg"]
