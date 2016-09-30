FROM solr:6.2

USER root
RUN apt-get update -y && apt-get install -y subversion 

COPY ./docker-entrypoint.sh /opt/docker-solr/scripts/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["solr"]
