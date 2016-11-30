set -e

# VARIABLES DE CONFIGURACION
export POSTGRES_CKAN_PASSWORD_CLI=
export SITE_CKAN_URL=

# ASIGNACION DE PASSWORD OBLIGATORIA
while [[ -z "$POSTGRES_CKAN_PASSWORD_CLI" ]]; do
    echo "Ingresa el password para la base de datos: "
    read POSTGRES_CKAN_PASSWORD_CLI
done

# ASIGNACION DE HOST OPCIONAL
echo "Ingresa el CKAN host (Default: http://localhost): "
read SITE_CKAN_URL

if [[ -z "$SITE_CKAN_URL" ]]; then
    SITE_CKAN_URL="http://localhost"
fi

# INSTALACION DE DEPENDENCIAS
{
  wget -qO- https://get.docker.com/ | sh
  wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python
  wget https://bootstrap.pypa.io/get-pip.py -O - | sudo python
} || {
  echo "Algo salio mal instalando las dependencias"
}


# CONSTRUCCION DE IMAGENES
{
    docker build -t ckan/ckan-postgres $(pwd)/dockerfiles/ckan-postgres/.
    docker build -t ckan/ckan-solr $(pwd)/dockerfiles/ckan-solr
    docker build -t ckan/ckan-base $(pwd)/dockerfiles/ckan
    docker build -t ckan/ckan-plugins $(pwd)/dockerfiles/ckan-plugins

} || {
    echo "Algo salio construyendo las imagenes Docker"
}

# LEVANTAR SERVICIOS SWARM
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
    # Se tira el nodo swarm y la red ckan
    docker swarm leave --force
    docker network rm mynetckan
}

# Creacion de usuario administrador
{
  docker exec -it $(docker ps --filter ancestor=ckan/ckan-plugins:latest -q) /usr/lib/ckan/bin/paster --plugin=ckan sysadmin add admin -c /project/development.ini
} || {
  echo "Ha ocurrido un error al crear el usuario administrador"
}