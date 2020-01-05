#!/usr/bin/env bash
#
# Development Environment management tool for Magento Commerce 
#
# @Arguments: [create|init|delete|start|stop|test|ssh|cli|magento|composer|versions] [-f|--force|-v|--verbose|--version|--debug]
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @source https://github.com/serge-kaimin/magento2-kubernetes-devbox
# shellcheck disable=SC2154
# shellcheck disable=SC1090

# make script exit when a command fails.
set -o errexit

# Print commands and their arguments as they are executed if --debug enabled
[[ -n ${Show_debug} ]] && set -x

#
## Change workdir if $Devbox_WORKDIR
# shellcheck disable=SC2154
[ -z "${Devbox_WORKDIR}" ] && devbox_dir=$PWD || devbox_dir=${Devbox_WORKDIR}

# shellcheck disable=SC1090
source "${devbox_dir}/scripts/bash-parameters-parsing.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/functions.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/host/parse_yaml_to_variables.sh"

##TODO check if --force
if [[ ! $(isMinikubeRunning) -eq 1 ]]; then
    #TODO validate minikube version
    status "Starting minikube"
    : "${Devbox_minikube_cpus:="2"}"
    : "${Devbox_minikube_memory:="2048"}"
    #TODO --kubernetes-version=v1.15.6
    #TODO enable heapster from config
    #TODO get variables cpu and memory from yaml or set default
    echo "minikube start --cpus=${Devbox_minikube_cpus} --memory=${Devbox_minikube_memory}"
    #TODO set parameters from Devbox_minikube_set
    #minikube config set kubernetes-version v1.15.6
    #TODO enable addons from
    : "${Devbox_minikube_addons_enable:="ingress"}"
    #minikube addons enable ingress
    #minikube addons enable heapster
  else 
    echo "Minikube is runnig stop it "
    exit 1
  fi
