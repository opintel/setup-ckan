#!/bin/sh
set -e

# Creacion de tablas y funciones postgis
psql --username "$POSTGRES_USER" -d $POSTGRES_DB -f /usr/share/postgresql/9.3/contrib/postgis-2.3/postgis.sql
psql --username "$POSTGRES_USER" -d $POSTGRES_DB -f /usr/share/postgresql/9.3/contrib/postgis-2.3/spatial_ref_sys.sql

# Ajustando permisos de las tablas geoespacioles
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d $POSTGRES_DB<<-EOSQL
    ALTER TABLE geometry_columns OWNER TO $POSTGRES_USER;
    ALTER TABLE spatial_ref_sys OWNER TO $POSTGRES_USER;
    SELECT postgis_full_version();
EOSQL

