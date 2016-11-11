# Creando keystore para el cluster
docker-machine create -d virtualbox --virtualbox-memory "1000" \
--engine-opt="label=com.function=consul"  keystore

eval $(docker-machine env keystore)

docker run --restart=unless-stopped -d -p 8500:8500 -h consul progrium/consul -server -bootstrap
docker ps
sleep 5

curl $(docker-machine ip keystore):8500/v1/catalog/nodes

# Creacion manager del cluster
docker-machine create -d virtualbox --virtualbox-memory "1000" \
--swarm --swarm-master \
--engine-opt="label=com.function=manager" \
--swarm-discovery="consul://$(docker-machine ip keystore):8500" \
--engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
--engine-opt="cluster-advertise=eth1:2376" manager

eval $(docker-machine env manager)

docker run --restart=unless-stopped -d -p 3376:2375 \
-v /var/lib/boot2docker:/certs:ro \
swarm manage --tlsverify \
--tlscacert=/certs/ca.pem \
--tlscert=/certs/server.pem \
--tlskey=/certs/server-key.pem \
consul://$(docker-machine ip keystore):8500

# Creando balanceador de carga
docker-machine create -d virtualbox --virtualbox-memory "500" \
--engine-opt="label=com.function=interlock" loadbalancer

eval $(docker-machine env loadbalancer)

sed -i -e "s|DockerURL = \"tcp://url_manager:3376\"|DockerURL = \"tcp://$(docker-machine ip manager):3376\"|" interlock/config.toml
cat interlock/config.toml
docker build -t ckan/interlock interlock

docker run \
    -P \
    -d \
    -ti \
    -v nginx:/etc/conf \
    -v /var/lib/boot2docker:/var/lib/boot2docker:ro \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name interlock \
    ckan/interlock \
    -D run -c /etc/config.toml

docker ps -a
docker logs interlock

sleep 10

docker run -ti -d \
  -p 80:80 \
  --label interlock.ext.name=nginx \
  --link=interlock:interlock \
  -v nginx:/etc/conf \
  --name nginx \
  nginx nginx -g "daemon off;" -c /etc/conf/nginx.conf

# Creando nodo de ckan
docker-machine create -d virtualbox --virtualbox-memory "500" \
--swarm \
--swarm-discovery="consul://$(docker-machine ip keystore):8500" \
--engine-opt="label=com.function=ckan" \
--engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
--engine-opt="cluster-advertise=eth1:2376" ckan

eval $(docker-machine env ckan)
# docker run -d swarm join --addr=$(docker-machine ip ckan):2376 consul://$(docker-machine ip keystore):8500
docker ps -a

sleep 5

eval $(docker-machine env --swarm manager)
docker info
sleep 10

# Creando nodo de solr
docker-machine create -d virtualbox --virtualbox-memory "1000" \
--swarm \
--swarm-discovery="consul://$(docker-machine ip keystore):8500" \
--engine-opt="label=com.function=solr" \
--engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
--engine-opt="cluster-advertise=eth1:2376" solr

#eval $(docker-machine env solr)
#docker run -d swarm join --addr=$(docker-machine ip solr):2376 consul://$(docker-machine ip keystore):8500

# Creando nodo de postgres
docker-machine create -d virtualbox --virtualbox-memory "1000" \
--swarm \
--swarm-discovery="consul://$(docker-machine ip keystore):8500" \
--engine-opt="label=com.function=postgres" \
--engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
--engine-opt="cluster-advertise=eth1:2376" postgres

#eval $(docker-machine env postgres)
#docker run -d swarm join --addr=$(docker-machine ip postgres):2376 consul://$(docker-machine ip keystore):8500

# Create Network
eval $(docker-machine env manager)
docker network create -d overlay ckan


# Lanzando postgres
eval $(docker-machine env postgres)
docker network ls
docker volume create --name db-data

docker build -t ckan/ckan-postgres ckan-postgres/

docker -H $(docker-machine ip manager):3376 run -t -d \
-v db-data:/var/lib/postgresql/data \
-e constraint:com.function==postgres \
-e POSTGRES_DB=ckan_default \
-e USER_DATASTORE=ckan \
-e DATABASE_DATASTORE=datastore_default \
-e POSTGRES_USER=ckan \
-e POSTGRES_PASSWORD=super-secure-pass \
-P \
--net="ckan" \
--name postgres ckan/ckan-postgres

# Lanzando solr
eval $(docker-machine env solr)
docker volume create --name solr-data

docker build -t ckan/ckan-solr ckan-solr/

docker -H $(docker-machine ip manager):3376 run -t -d \
-e constraint:com.function==solr \
-v solr-data:/opt/solr \
-p 8080:8080 \
--net="ckan" \
--name solr ckan/ckan-solr

# Lanzando ckan
eval $(docker-machine env ckan)
docker build -t ckan/ckan-base ckan/
docker build -t ckan/ckan-plugins ckan-plugins/

docker -H $(docker-machine ip manager):3376 run -t -d \
  --name ckan \
  --label=interlock.hostname=datos \
  --label=interlock.domain=puebla.gob \
  -e constraint:com.function==ckan \
  -e INIT_DBS=true \
  -e TEST_DATA=true \
  -e POSTGRES_ENV_POSTGRES_USER=ckan \
  -e POSTGRES_ENV_USER_DATASTORE=ckan \
  -e POSTGRES_ENV_POSTGRES_PASSWORD=super-secure-pass \
  -e POSTGRES_ENV_POSTGRES_DB=ckan \
  -e POSTGRES_ENV_DATABASE_DATASTORE=datastore_default \
  -e SOLAR_IP=$(docker-machine ip solr) \
  -e POSTGRES_IP=$(docker-machine ip postgres) \
  -e CKAN_SITE_URL=http://localhost/ \
  -p 80:5000 ckan/ckan-plugins