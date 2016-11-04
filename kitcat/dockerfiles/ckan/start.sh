#!/bin/sh

# Adjust config file
sed -i -e "s|#solr_url = http://127.0.0.1:8983/solr|solr_url = http://$SOLR_PORT_8983_TCP_ADDR:$SOLR_PORT_8983_TCP_PORT/solr|" /project/development.ini
sed -i -e "s|ckan.site_url =|ckan.site_url = http://localhost|" /project/development.ini
sed -i -e "s|ckan_default:pass@localhost/ckan_default|$POSTGRES_ENV_POSTGRES_USER:$POSTGRES_ENV_POSTGRES_PASSWORD@$POSTGRES_PORT_5432_TCP_ADDR/$POSTGRES_ENV_POSTGRES_USER|" /project/development.ini

# Create tables
if [ "$INIT_DBS" = true ]; then
  $CKAN_HOME/bin/paster --plugin=ckan db init -c /project/development.ini
  $CKAN_HOME/bin/paster --plugin=ckan datastore set-permissions -c /project/development.ini | ssh $POSTGRES_PORT_5432_TCP_ADDR sudo -u postgres psql --username $POSTGRES_USER --set ON_ERROR_STOP=1
fi

# Crea datos de prueba
if [ "$TEST_DATA" = true]; then
  $CKAN_HOME/bin/paster --plugin=ckan create-test-data -c /project/development.ini
fi

# Serve site
exec apachectl -DFOREGROUND
