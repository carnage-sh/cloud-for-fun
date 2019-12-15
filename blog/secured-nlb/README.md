# Using this demonstration

## Configuring the project

In order to use this configuration, you would have to configure it:

- Create a file named `variables.auto.tfvars` that contains:
  - `public_key` is the string of your private key usually in `~/.ssh/id_rsa.pub`
  - `profile` is a awscli profile that exists in your `~/.aws/credentials` file
  - `personal_ip` is your ip you can get with `curl -4 ifconfig.co`

```text
public_key = "ssh-rsa AAAA..."
profile = "default"
personal_ip = "3.0.0.0"
```

- Run `terraform init` to download the aws module

- check the configuration for `aws_instance.public` and `aws_instance.private`
  by running the commands below:

```shell
terraform state show "aws_instance.public"
terraform state show "aws_instance.private"
```

## connecting to the private server

You should be able to connect to the server that is not exposed with a proxyjump
SSH. On Linux or on MacOS, run something like below:

```shell
ssh ec2-user@${public_ip_for_public_instance} ec2-user@{private_ip_for_private_instance}
```

## Installing nginx

To install nginx, you can run the command below:

```shell
sudo amazon-linux-extras install nginx1
sudo systemctl start nginx
curl localhost
```

## Testing the security

Assuming you've correctly set the variables, you should be able:

- To figure out the NLB cname with
  `terraform state show aws_lb.loadbalancer`
- To figure out the EIP you've attached to the NLB with 
  `terraform state show aws_eip.loadbalancer`

You should be able to access the http (via curl) as well as the ssh protocol
both with the alias and the IP for the NLB. If you change the value in
`personal_ip` for some one that is not your and apply the change, you should
not be able to get the access anymore.

