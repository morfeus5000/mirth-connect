FROM java

ENV MIRTH_CONNECT_VERSION 3.3.1.7856.b91
RUN useradd -u 1000 mirth
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget 
VOLUME /opt/mirth-connect/appdata

RUN cd /tmp
RUN wget http://downloads.mirthcorp.com/connect/3.3.1.7856.b91/mirthconnect-3.3.1.7856.b91-unix.tar.gz
RUN rm -f mirthconnect-3.3.1.7856.b91-unix.tar.gz
RUN mv Mirth\ Connect/* /opt/mirth-connect/
RUN chown -R mirth /opt/mirth-connect

WORKDIR /opt/mirth-connect

EXPOSE 8080 8443

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["java", "-jar", "mirth-server-launcher.jar"]
