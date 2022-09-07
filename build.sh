#!/bin/bash

DOCKER_BUILDKIT=1
#docker build -t itksnap-build-env .

docker build -t itksnap-build-env-alt -f Dockerfile.alt .