set -e
{
    # Levantar el swarm local
    docker swarm init --advertise-addr 127.0.0.1
    # Levantar la overlay network 
    docker network create -d overlay mynetckan

    # Levantar servicio de postgres
    docker service create \
    --replicas 1 \
    --constraint "node.hostname == $(hostname)" \
    --env POSTGRES_DB=ckan_default \
    --env USER_DATASTORE=ckan \
    --env DATABASE_DATASTORE=datastore_default \
    --env POSTGRES_USER=ckan \
    --env POSTGRES_PASSWORD=$POSTGRES_CKAN_PASSWORD_CLI \
    --publish 5432:5432/tcp \
    --network mynetckan \
    --name postgres ckan/ckan-postgres

    # Levantar servicio de solr
    docker service create \
    --constraint "node.hostname == $(hostname)" \
    --name solr \
    --network mynetckan \
    --publish 8080:8080/tcp ckan/ckan-solr

    sleep 25

    # Levantar servicio de ckan
    docker service create \
      --constraint "node.hostname == $(hostname)" \
      --name ckan \
      --env INIT_DBS=true \
      --env TEST_DATA=true \
      --env CKAN_SITE_URL=$SITE_CKAN_URL \
      --env POSTGRES_ENV_POSTGRES_USER=ckan \
      --env POSTGRES_ENV_USER_DATASTORE=ckan \
      --env POSTGRES_ENV_POSTGRES_PASSWORD=$POSTGRES_CKAN_PASSWORD_CLI \
      --env POSTGRES_ENV_POSTGRES_DB=ckan_default \
      --env POSTGRES_ENV_DATABASE_DATASTORE=datastore_default \
      --env SOLAR_IP=solr \
      --env POSTGRES_IP=postgres \
      --network mynetckan \
      --publish 80:5000/tcp ckan/ckan-plugins

    echo "Se han levantado los servicios exitosamente"
} || {
    echo "Ha ocurrido un error al levantar el SWARM"
}
