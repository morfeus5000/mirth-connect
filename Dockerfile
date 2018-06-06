# See https://github.com/brandonstevens/mirth-connect-docker
FROM java:8

ENV MIRTHCONNECT_VERSION 3.5.0.8232.b2153
ENV MIRTHCONNECT_SHA1SUM 0550d00905ea7161a47d78cedbae35699a5f1b67

# Install NGiNX
RUN apt-get update && apt-get install -y --no-install-recommends nginx && \
  rm -rf /var/lib/apt/lists/*
RUN rm -f /etc/nginx/sites-enabled/default

# Install Mirth Connect
RUN cd /tmp && \
  wget https://s3.amazonaws.com/downloads.mirthcorp.com/connect/$MIRTHCONNECT_VERSION/mirthconnect-$MIRTHCONNECT_VERSION-unix.tar.gz && \
  echo "$MIRTHCONNECT_SHA1SUM" mirthconnect-$MIRTHCONNECT_VERSION-unix.tar.gz | sha1sum -c && \
  tar xvzf mirthconnect-$MIRTHCONNECT_VERSION-unix.tar.gz && \
  rm -f mirthconnect-$MIRTHCONNECT_VERSION-unix.tar.gz && \
  mkdir -p /opt/mirthconnect && \
  mv Mirth\ Connect/* /opt/mirthconnect/ && \
  mkdir -p /opt/mirthconnect/appdata
WORKDIR /opt/mirthconnect

# Install nc (in order to determine when Mirth Connect is listening)
RUN apt-get update && apt-get install -y netcat && \
  rm -rf /var/lib/apt/lists/*

COPY templates/conf/mirth.properties /opt/mirthconnect/conf/mirth.properties

# NGiNX (X-Forwarded-Proto Proxy)
EXPOSE 3000

# Mirth (Direct)
EXPOSE 80 443

# 10 unmapped channels
EXPOSE 9661-9670

COPY templates/etc /etc
COPY templates/bin /usr/local/bin

CMD ["/usr/local/bin/mirthconnect-wrapper.sh"]