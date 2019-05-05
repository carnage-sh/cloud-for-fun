# ecr-helper

`ecr-helper` is a script that is part of the Knative project that creates a
secret/service account so that a `build` can connect to ECR. For security
reasons, the token that is stored in the secret and is a docker token expires
after 12 hours. These resources:

- create an ECS registry;
- package that script in a docker image and store it in the registry;
- create the environment to welcome your deployment: namespace, permissions...
- create the AWS user/role that can access the registry
- execute a container from image in a separate namespace with a deployment;
- set the required permissions on AWS and Kubernetes to perform the work;

## Create an AWS ECR repository

The set of commands below creates the repository to store the docker
image. We assume we are connected to the right account:

```shell
aws ecr create-repository \
  --repository-name=ecr-helper

aws ecr set-repository-policy \
  --repository-name=ecr-helper \
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

## Package the scripts and push it to the repository

To build/push the docker images, run the script below:

```shell
make
make push
```

## Create the environment for the deployment

The deployment that runs the ecr-helper should run in a separate namespace. It
should have the permissions to create a secret with the docker credentials in
the namespace that runs Knative... `ecr-helper-rbac.yaml` contains the
resource required, it assumes:

- The welcoming namespace is `ecr-helper`
- The Knative namespace is `default`

Run the script below to create the resources:

```shell
kubectl apply -f ecr-helper-rbac.yaml
```

## Create an AWS user or role that can access the ACS registry

Whether you rely on a user and its access key or a role depends on your
kubernetes setup. If you have Kubeiam or Kiam in place go for a role.
Below are the example for a user and its key:

```shell
aws iam create-user \
  --user-name ecr-helper

aws iam create-policy --policy-name=ecr-helper-policy \
   --policy-document='{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Sid": "ECRKnativeToken",
             "Effect": "Allow",
             "Resource": [
                "*"
             ],
             "Action": [
                 "ecr:GetAuthorizationToken"
             ]
         }
     ]
 }' --description "Helper to access to ECR" \
   --query='Policy.Arn'

 aws iam attach-user-policy \
    --user-name ecr-helper \
    --policy-arn arn:aws:iam::${AWS_ACCOUNT}:policy/ecr-helper-policy

aws iam create-access-key --user-name=ecr-helper
```

The last command provides a pair of access/secret keys, register them as a
secret in the `ecr-helper` namespace by remplacing the `XXX` and `xxx` and running
the command below:

```shell
kubectl create secret generic ecr-helper \
  --namespace=ecr-helper \
  --from-literal=aws_access_key_id=XXX \
  --from-literal=aws_secret_access_key=xxx
```

## Run the Deployment

To start the deployment, you should have the `AWS_ACCOUNT` and
`AWS_DEFAULT_REGION` environment variable set. Run:

```shell
make deploy
```

You can check it is running fine, starting a pod with:

```shell
kubectl get all -n ecr-helper
```

The `make logs` command, once the pod has started should show the logs,
it should look like this:

```text
Deployment: ecr-helper-57964b6d97-qmdsv
serviceaccount/builder-sa configured
secret/ecr-creds configured
secret/ecr-creds-pull configured
the secret will expire at Sat May  4 17:44:27 UTC 2019.
```

