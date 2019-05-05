# Knative Event

## Create an AWS ECR repository

The set of commands below creates the repository to store the docker
image. We assume we are connected to the right account:

```shell
aws ecr create-repository \
  --repository-name=kevent

aws ecr set-repository-policy \
  --repository-name=kevent \
  --policy-text='{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchDeleteImage",
                "ecr:BatchGetImage",
                "ecr:CompleteLayerUpload",
                "ecr:DeleteRepository",
                "ecr:DeleteRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:InitiateLayerUpload",
                "ecr:ListImages",
                "ecr:PutImage",
                "ecr:SetRepositoryPolicy",
                "ecr:UploadLayerPart"
            ]
        }
    ]
}'
```

## Build and push the container

```shell
docker build -t kevent:0.0.3 .
docker tag kevent:0.0.3 \
  ${AWS_ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com/kevent:0.0.3
aws ecr get-login --no-include-email |sh
docker push ${AWS_ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com/kevent:0.0.3
```
