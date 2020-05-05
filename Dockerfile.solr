FROM solr:8

COPY solr/conf /opt/config
RUN precreate-core blacklight-development /opt/config && precreate-core blacklight-test /opt/config exec solr -f
