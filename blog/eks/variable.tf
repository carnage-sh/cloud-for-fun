variable "name" {
  type        = map(string)
  description = "Stack Name"

  default = {
    default = "princess"
  }
}

variable "sshkey" {
  type        = map(string)
  description = "A sample SSH key used to connect to the instances"

  default = {
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFiDLWSBFRww+0xt8lURUxVtTgZCFoj5zctK7GJ6zqNBQ6Yd5d1JDoGf6o6qC+tmwAobMSU8kPT+1JJRQV4uOrZTLnGhbeRlcydaf9GMzKYHdTSpBYf1+cQJ+wgz6AU9hZQYgbVTlOX/1bdrZlgOuOz5BETXeOmd4P9ZQuRexyiSGSQKq76ydde49T0dhlB/g2DfEU0UbogH/QTQQ7I5QoJ4Myg5twHR0dGpx/DG1ZeuvG+XVTC7GK7EMIwXmmnL1/8S74ir+6BwlfiGWJDUhqwwF34+vJYjOErLt1NIAKigYpXhtf8Nd7bROYa4sGSxKGAMMJ6HkFEU0P3SUjkHt3"
  }
}

