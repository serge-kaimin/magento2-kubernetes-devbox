#!/usr/bin/env bash
#
# Initialize minikube environment for Magento Commerce 
#
# @Arguments: []
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
#if [[ ! $(isKindRunning) -eq 1 ]]; then

# https://kind.sigs.k8s.io/docs/user/quick-start/
kind create cluster --name kind
#kind delete cluster --name kind
#kubectl get pod --context kind-kind
kubectl get service --all-namespaces
#kubectl cluster-info --context kind-kind
