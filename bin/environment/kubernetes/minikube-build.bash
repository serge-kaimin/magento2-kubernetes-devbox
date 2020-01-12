#!/usr/bin/env bash
#
# Build images inside minikube environment for Magento Commerce 
#
# @Arguments: []
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @source https://github.com/serge-kaimin/magento2-kubernetes-devbox
# shellcheck disable=SC2154
# shellcheck disable=SC1090

# make script exit when a command fails.
set -o errexit

# Print commands and their arguments as they are executed if --debug enabled
#[[ -n ${Show_debug} ]] && set -x

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

eval "$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"

echo "Images to build on minikube"

##TODO if instance name in args, then build only this instance
##TODO check if required to add [instance-name]- to images, to be sure images are not linked bewteen instances
##TODO check if --force
if [[ ! $(isMinikubeRunning) -eq 1 ]]; then

    #TODO loop for all instances

    instance=${Devbox_env_default}
    echo "Building instance etc/helm/${instance}/images/"
    cd "${devbox_dir}/etc/helm/${instance}/images/" && build.bash

fi

#cd "${devbox_dir}/scripts" && eval $(minikube docker-env) && docker build -t magento2-monolith:dev -f ../etc/docker/monolith/Dockerfile ../scripts