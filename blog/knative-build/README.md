# Knative build

1. Create a repository
2. Create a user/password and register it with the secret/service account
3. Install Kaniko templatre

https://github.com/knative/build-templates/tree/master/kaniko
https://knative.dev/docs/serving/samples/source-to-url-go/

## Create an AWS ECR repository

The set of commands below creates the repository to store the docker
image. We assume we are connected to the right account:

```shell
aws ecr create-repository \
  --repository-name=hi

aws ecr set-repository-policy \
  --repository-name=hi \
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
