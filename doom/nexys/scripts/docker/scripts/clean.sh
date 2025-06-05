#!/bin/sh
docker compose down
docker container rm doom_container
docker image rm docker-doom_app:latest
docker volume rm docker_code_volume
docker volume rm docker_platformio_volume
