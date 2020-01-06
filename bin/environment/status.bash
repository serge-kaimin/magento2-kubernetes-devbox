#!/usr/bin/env bash
#
# Development Environment management tool for Magento Commerce 
#
# @Arguments: [create|init|delete|status|start|stop|test|ssh|cli|magento|composer|versions] [-f|--force|-v|--verbose|--version|--debug]
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

eval "$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"

# shellcheck disable=SC2034
Arg_parser_prefix="Status_"
# shellcheck disable=SC2046
eval $(parse_params "${@}")

#get kubernetes name from Devbox.yaml, default=minikube
kubernetes="${Devbox_kubenetes_default}"

[[ -n ${Status_verbose} ]] && echo "Default kubernetes: ${Devbox_kubenetes_default}"

command_run="${devbox_dir}/bin/environment/status/${kubernetes}.bash"

eval "${command_run}"

echo "Kubernetes Cluster info"

kubectl cluster-info 
