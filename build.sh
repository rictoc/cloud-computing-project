#!/bin/bash
registry="$1.dkr.ecr.$2.amazonaws.com"

aws ecr get-login-password \
--region $2 | \
docker login \
--username AWS \
--password-stdin $registry

docker build -t $registry/$3 $4

aws ecr create-repository --repository-name $3

docker push $registry/$3
