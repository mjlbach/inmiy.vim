#!/usr/bin/env bash

CONTAINER_ARCHIVE=$(nix-build docker.nix)
PODMAN_CONTAINER=$(podman load -q < $CONTAINER_ARCHIVE)
PODMAN_IMAGE_ID=$(echo $PODMAN_CONTAINER | awk '{print $3}')
echo made container
podman run -it -v=$HOME:$HOME $PODMAN_IMAGE_ID
