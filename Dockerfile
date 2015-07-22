FROM java:8

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4

ENV ELASTICSEARCH_VERSION 1.7.0
ENV LOGSTASH_MAJOR 1.5
ENV LOGSTASH_VERSION 1:1.5.2-1
ENV KIBANA_MAJOR 4.1.1

RUN echo "deb http://packages.elasticsearch.org/elasticsearch/${ELASTICSEARCH_VERSION%.*}/debian stable main" > /etc/apt/sources.list.d/elasticsearch.list
RUN echo "deb http://packages.elasticsearch.org/logstash/${LOGSTASH_MAJOR}/debian stable main" > /etc/apt/sources.list.d/logstash.list
RUN apt-get update && apt-get install -y supervisor \
    elasticsearch=$ELASTICSEARCH_VERSION logstash=$LOGSTASH_VERSION

RUN wget -P /tmp https://download.elastic.co/kibana/kibana/kibana-${KIBANA_MAJOR}-linux-x64.tar.gz && \
  mkdir /srv/kibana && \
  tar --strip-components=1 -C /srv/kibana -xvf /tmp/kibana-${KIBANA_MAJOR}-linux-x64.tar.gz

# 9200/9300 are elasticsearch API ports
# 5000 is logstash ingress
# 5601 is kibana frontend
EXPOSE 9200 9300 5000 5601

### APPLICATION CODE ###
ENV FILES_DIR ./container/files

# path resolution 
ENV PATH /opt/logstash/bin:$PATH
ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV PATH /srv/kibana/bin:$PATH

# elasticsearch setup
VOLUME /usr/share/elasticsearch/data
RUN ln -s /etc/elasticsearch /usr/share/elasticsearch/config

# logstash config
COPY $FILES_DIR/etc/logstash/conf.d /etc/logstash/conf.d
RUN mkdir -p /etc/pki/tls/certs
COPY $FILES_DIR/etc/pki/tls/certs/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
RUN mkdir /etc/pki/tls/private
COPY $FILES_DIR/etc/pki/tls/private/logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder.key
RUN mkdir -p /opt/logstash
COPY $FILES_DIR/opt/logstash/patterns /opt/logstash/patterns

### SUPPORTIVE SERVICES ###
# supervisor setup
COPY $FILES_DIR/etc/supervisor/conf.d /etc/supervisor/conf.d

# supervisor setup
COPY $FILES_DIR/etc/supervisor/conf.d /etc/supervisor/conf.d

CMD ["supervisord", "-n"]