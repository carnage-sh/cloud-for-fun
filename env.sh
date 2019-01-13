#!/usr/bin/env bash

export PATH="$(git rev-parse --show-toplevel)/tools:$PATH"
export TF_VAR_sshkey="$(cat $HOME/.ssh/id_rsa.pub)"
