#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
#

FROM jeanblanchard/java:serverjre-8
MAINTAINER Mike Fuller <mike.fuller@redpillanalytics.com>

ARG SDC_USER=sdc
ARG SDC_VERSION=3.11.0

# We set a UID/GID for the SDC user because certain test environments require these to be consistent throughout
# the cluster. We use 20159 because it's above the default value of YARN's min.user.id property.
ARG SDC_UID=20159

RUN apk --no-cache add bash \
    curl \
    krb5-libs \
    libstdc++ \
    libuuid \
    sed \
    perl

# The paths below should generally be attached to a VOLUME for persistence.
# SDC_CONF is where configuration files are stored. This can be shared.
# SDC_DATA is a volume for storing collector state. Do not share this between containers.
# SDC_LOG is an optional volume for file based logs.
# SDC_RESOURCES is where resource files such as runtime:conf resources and Hadoop configuration can be placed.
# STREAMSETS_LIBRARIES_EXTRA_DIR is where extra libraries such as JDBC drivers should go.
ENV SDC_CONF=/etc/sdc \
    SDC_DATA=/data \
    SDC_DIST="/opt/streamsets-datacollector-${SDC_VERSION}" \
    SDC_LOG=/logs \
    SDC_RESOURCES=/resources
ENV STREAMSETS_LIBRARIES_EXTRA_DIR="${SDC_DIST}/streamsets-libs-extras"

RUN addgroup -S -g ${SDC_UID} ${SDC_USER} && \
    adduser -S -u ${SDC_UID} -G ${SDC_USER} ${SDC_USER}

RUN cd /tmp && \
  curl -O -L "https://archives.streamsets.com/datacollector/${SDC_VERSION}/tarball/streamsets-datacollector-core-${SDC_VERSION}.tgz" && \
  curl -O -L "https://archives.streamsets.com/datacollector/${SDC_VERSION}/tarball/streamsets-datacollector-jdbc-lib-${SDC_VERSION}.tgz" && \
  curl -O -L "https://archives.streamsets.com/datacollector/${SDC_VERSION}/tarball/streamsets-datacollector-google-cloud-lib-${SDC_VERSION}.tgz" && \
  #curl -O -L "https://archives.streamsets.com/datacollector/${SDC_VERSION}/tarball/streamsets-datacollector-apache-kafka_0_10-lib-${SDC_VERSION}.tgz" && \
  #curl -O -L "https://archives.streamsets.com/datacollector/${SDC_VERSION}/tarball/streamsets-datacollector-aws-lib-${SDC_VERSION}.tgz" && \
  #curl -O -L "https://archives.streamsets.com/datacollector/${SDC_VERSION}/tarball/streamsets-datacollector-stats-lib-${SDC_VERSION}.tgz" && \
  tar xvf "streamsets-datacollector-core-${SDC_VERSION}.tgz" -C /opt/ && \
  tar xvf "streamsets-datacollector-jdbc-lib-${SDC_VERSION}.tgz" -C /opt/ && \
  tar xvf "streamsets-datacollector-google-cloud-lib-${SDC_VERSION}.tgz" -C /opt/ && \
  #tar xzf "streamsets-datacollector-apache-kafka_0_10-lib-${SDC_VERSION}.tgz" -C /opt/ && \
  #tar xzf "streamsets-datacollector-aws-lib-${SDC_VERSION}.tgz" -C /opt/ && \
  #tar xzf "streamsets-datacollector-stats-lib-${SDC_VERSION}.tgz" -C /opt/ && \
  #rm  "/tmp/streamsets-datacollector-core-${SDC_VERSION}.tgz" "/tmp/streamsets-datacollector-apache-kafka_0_10-lib-${SDC_VERSION}.tgz" "/tmp/streamsets-datacollector-aws-lib-${SDC_VERSION}.tgz" "/tmp/streamsets-datacollector-stats-lib-${SDC_VERSION}.tgz"
  rm  "/tmp/streamsets-datacollector-core-${SDC_VERSION}.tgz" "/tmp/streamsets-datacollector-jdbc-lib-${SDC_VERSION}.tgz" "/tmp/streamsets-datacollector-google-cloud-lib-${SDC_VERSION}.tgz"

# Add logging to stdout to make logs visible through `docker logs`.
RUN sed -i 's|INFO, streamsets|INFO, streamsets,stdout|' "${SDC_DIST}/etc/sdc-log4j.properties"

# Create necessary directories.
RUN mkdir -p /mnt \
    "${SDC_DATA}" \
    "${SDC_LOG}" \
    "${SDC_RESOURCES}"

# Move configuration to /etc/sdc
RUN mv "${SDC_DIST}/etc" "${SDC_CONF}"

# Use short option -s as long option --status is not supported on alpine linux.
RUN sed -i 's|--status|-s|' "${SDC_DIST}/libexec/_stagelibs"

# Setup filesystem permissions.
RUN chown -R "${SDC_USER}:${SDC_USER}" "${SDC_DIST}/streamsets-libs" \
    "${SDC_CONF}" \
    "${SDC_DATA}" \
    "${SDC_LOG}" \
    "${SDC_RESOURCES}" \
    "${STREAMSETS_LIBRARIES_EXTRA_DIR}"

#COPY pre-stop.sh /tmp/
#RUN chmod +x /tmp/pre-stop.sh

USER ${SDC_USER}
EXPOSE 18630
ENTRYPOINT [ "sh", "-c", "$SDC_DIST/bin/streamsets dc" ]

#ENTRYPOINT ["/opt/streamsets-datacollector-3.11.0/bin/streamsets", "dc"]
#COPY docker-entrypoint.sh /
#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["dc", "-exec"]
