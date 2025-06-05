#!/bin/sh

export COMPOSE_BAKE=true
docker compose build
docker compose create
