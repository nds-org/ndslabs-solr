#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- solr "$@"
fi

if [[ "$VERBOSE" = "yes" ]]; then
    set -x
fi

INIT_LOG=${INIT_LOG:-/opt/docker-solr/init.log}

if [[ "$1" = 'solr' ]]; then

    # execute files in /docker-entrypoint-initdb.d before starting solr
    # for an example see docs/set-heap.sh
    shopt -s nullglob
    for f in /docker-entrypoint-initdb.d/*; do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *)        echo "$0: ignoring $f" ;;
        esac
        echo
    done
     
    if [ ! -f "/opt/solr/data/solr" ]; then 
        echo "Initializing directory /opt/solr/data"
        mkdir -p /opt/solr/data
        chmod -R a+w /opt/solr/data
        cp -r /opt/solr/server/solr /opt/solr/data

    fi
    /opt/solr/bin/solr start -f -s /opt/solr/data/solr &

    echo "Waiting for solr"
    wait_seconds=${WAIT_SECONDS:-5}
    if ! /opt/docker-solr/scripts/wait-for-solr.sh "$max_try" "$wait_seconds"; then
        echo "Could not start Solr."
        if [ -f /opt/solr/server/logs/solr.log ]; then
            echo "Here is the log:"
            cat /opt/solr/server/logs/solr.log
        fi
        exit 1
    fi

    if [ -n "$CORE_NAME" ]; then 
      ls /opt/solr/data/solr/
      if [ -d "/opt/solr/data/solr/$CORE_NAME" ]; then
          echo "skipping core creation"
      else
          echo "Creating core $CORE_NAME"
          /opt/solr/bin/solr create_core -c $CORE_NAME 

          # See https://github.com/docker-solr/docker-solr/issues/27
          echo "Checking core"
          if ! wget -q -O - 'http://localhost:8983/solr/admin/cores?action=STATUS' | grep -q instanceDir; then
            echo "Could not find any cores"
            exit 1
          fi
          echo "Created core $CORE_NAME"
      fi

      # Assumes files are in solr/conf
      if [ -n "$CONFIG_REPO" ]; then

          # https://github.com/nds-org/ndslabs-hydra/trunk/solr/conf
          rm -rf conf
          cd /opt/solr/data/solr/$CORE_NAME/
          svn checkout --force $CONFIG_REPO 
          curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=$CORE_NAME"
      fi
    fi

    wait
    echo "Exiting"
else 
  exec "$@"
fi

