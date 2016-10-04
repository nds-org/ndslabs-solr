# Solr 6.2

This is a preliminary implementation of the [Solr](http://lucene.apache.org/solr/) Docker image for use with the NDS Labs system. 

The image is referenced by the [NDS Labs Service Catalog](https://github.com/nds-org/ndslabs-specs).

## Environment variables
This image supports two environment variables for custom configuration:

* CORE_NAME: Name of the Solr Core.  If CORE_NAME is specified, then the core is created during container initialization if it doesn't exist.
* CONFIG_REPO: SVN compatible path to a directory containing custom Solr configuration. If specified, this will be checked out using "svn checkout" to replace the default "conf" directory for the core.

## Documentation
Documentation for Solr can be found here: http://lucene.apache.org/solr/6_2_1/index.html

## See also
* https://github.com/nds-org/ndslabs
* https://github.com/nds-org/ndslabs-specs
