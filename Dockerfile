FROM java:8

# RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4

### SETUP ###
# apt-transport-https is for apt-get update failing at apt-get update in elasticsearch
RUN apt-get update -q \
  && apt-get install -yq apt-transport-https


### ELASTICSEARCH ###
ENV ELASTICSEARCH_VERSION 2.3.3
VOLUME /usr/share/elasticsearch/data

# 9200/9300 are elasticsearch API ports
EXPOSE 9200 9300

# installation
RUN wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
RUN apt-get update \
  && apt-get install elasticsearch

# path resolution
ENV PATH /usr/share/elasticsearch/bin:$PATH

# debian-specific issue?
# config is installed at /etc/elasticsearch
# ...but elasticsearch looks for it in /usr/share/elasticsearch/config
RUN ln -s /etc/elasticsearch /usr/share/elasticsearch/config


### LOGSTASH ###
# ENV LOGSTASH_MAJOR 1.5
# ENV LOGSTASH_VERSION 1:1.5.2-1
#
# # 5000 is logstash ingress
# EXPOSE 5000
#
# # installation
# RUN echo "deb http://packages.elasticsearch.org/logstash/${LOGSTASH_MAJOR}/debian stable main" > /etc/apt/sources.list.d/logstash.list
# RUN apt-get install -yq logstash=$LOGSTASH_VERSION
#
# # path resolution
# ENV PATH /opt/logstash/bin:$PATH
#
# # logstash config
# # see bin/generate-ssl for the command to generate an ssl certificate and key
# COPY $FILES_DIR/etc/logstash/conf.d /etc/logstash/conf.d
# RUN mkdir -p /etc/pki/tls/certs
# COPY $FILES_DIR/etc/pki/tls/certs/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
# RUN mkdir /etc/pki/tls/private
# COPY $FILES_DIR/etc/pki/tls/private/logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder.key
# RUN mkdir -p /opt/logstash
# COPY $FILES_DIR/opt/logstash/patterns /opt/logstash/patterns


### KIBANA ###
# ENV KIBANA_MAJOR 4.1.1
#
# # 5601 is kibana frontend
# EXPOSE 5601
#
# # installation
# RUN wget -P /tmp https://download.elastic.co/kibana/kibana/kibana-${KIBANA_MAJOR}-linux-x64.tar.gz && \
#   mkdir /srv/kibana && \
#   tar --strip-components=1 -C /srv/kibana -xvf /tmp/kibana-${KIBANA_MAJOR}-linux-x64.tar.gz
#
# # path resolution
# ENV PATH /srv/kibana/bin:$PATH


### SUPERVISOR ###
# RUN apt-get install -y supervisor
#
# # supervisor config
# COPY $FILES_DIR/etc/supervisor/conf.d /etc/supervisor/conf.d


### APPLICATION CODE ###
ENV FILES_DIR ./container/files


CMD ["supervisord", "-n"]
