# AWS X-Ray Instrumentation

ECS Fargate cluster with X-Ray Golang application instrumentation.

<img src=".assets/xray.png" />

Create the infrastructure:

```
terraform -chdir=aws init
terraform -chdir=aws apply -auto-approve
```

Once the cluster is created, build and push the application image to ECR:

```sh
bash ./app/ecr.sh
```
