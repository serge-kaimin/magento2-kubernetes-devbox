#!/usr/bin/env bash
#
# Development Environment start script for Magento Commerce
#
# @Arguments: [] [-f|--force|-v|--verbose|--version|--debug]
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
# shellcheck disable=SC1090
source "${devbox_dir}/bin/include/common.bash"


eval "$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"

parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_"

#
## Command: devbox.bash environment start
#
environment_start()
{
  #bash "${devbox_dir}/scripts/host/check_requirements.sh"

    #TODO check if run: start [instance]

    echo "List of instances available: ${Devbox_env_instances}"
    
    # shellcheck disable=SC2116
    for instance in $(echo "${Devbox_env_instances}"); do
        instance_enabled="Devbox_env_instance_${instance}_enabled"
        if [[ "${!instance_enabled}" == "true" ]] ; then
            echo "Instance: ${instance} - enabled"

        fi
    done

    #
    # check what is kubernetes ${Devbox_kubernetes_defaulf}
    #
    echo "Kubernetes: ${Devbox_kubernetes_defaulf}"
    case ${Devbox_kubernetes_defaulf} in
        minikube)
            #start minikube
            "${devbox_dir}/bin/environment/kunernetes/minikube-start.bash"
            ;;
        kind)
            #start kind
            #"${devbox_dir}/bin/environment/kunernetes/kind-start.bash"
            # https://kind.sigs.k8s.io/docs/user/quick-start/
            #kind create cluster #--name kind
            #kubectl cluster-info --context kind-kind
            ;;
    esac

}

environment_start

# end 