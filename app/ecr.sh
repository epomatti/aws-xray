#!/bin/bash

account=$(aws sts get-caller-identity --query "Account" --output text)
region="us-east-2"

docker build -t xray-app-golang .
docker tag xray-app-golang "$account.dkr.ecr.$region.amazonaws.com/awsomeapp:latest"
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin "$account.dkr.ecr.$region.amazonaws.com"
docker push "$account.dkr.ecr.$region.amazonaws.com/awsomeapp:latest"