#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER magnolia_author;
    CREATE DATABASE magnolia_author;
    GRANT ALL PRIVILEGES ON DATABASE magnolia_author TO magnolia_author;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER magnolia_public;
    CREATE DATABASE magnolia_public;
    GRANT ALL PRIVILEGES ON DATABASE magnolia_public TO magnolia_public;
EOSQL