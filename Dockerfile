FROM solr:6.2

COPY ./docker-entrypoint.sh /opt/docker-solr/scripts/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["solr"]
