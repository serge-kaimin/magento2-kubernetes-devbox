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

#
## Change workdir if $Devbox_WORKDIR
# shellcheck disable=SC2154
[ -z "${Devbox_WORKDIR}" ] && devbox_dir=$PWD || devbox_dir=${Devbox_WORKDIR}

# shellcheck disable=SC1090
source "${devbox_dir}/scripts/bash-parameters-parsing.sh"
# shellcheck disable=SC2034
Arg_parser_prefix="ssh_"
# shellcheck disable=SC2046
eval $(parse_params "${@}")
# Print commands and their arguments as they are executed if --debug enabled
[[ -n ${ssh_debug} ]] && set -x

if [ -d "./../bin/" ] && [ -n "${Devbox_WORKDIR}" ]; then
  #echo "${Devbox_WORKDIR}"
  echo "script environment.sh should not run from bin/ directory"
  echo "current directory is: ${PWD}"
  echo ""
  echo "should you change directory"
  echo "  cd ../bin | bin/environment.sh"
  echo "        or" 
  echo "  export Devbox_WORKDIR=[path to your devbox.bash WORKDIR]"
  exit 1
fi

# shellcheck disable=SC1090
source "${devbox_dir}/scripts/functions.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/host/parse_yaml_to_variables.sh"


# {1} - pod name
# {2} - container name
function loginToPodContainer()
{
    #if [[ -z "${1}" ]] || [[ -z "${2}" ]]; then
    #    error "Container and pod names must be specified"
    #fi
    pod_name="${1}"
    container_name="${2}"
    echo "Logging in to '${container_name}' container in '${pod_name}' pod"
    #kubectl exec -it "${pod_name}" --container "${container_name}" -- /bin/bash
    kubectl exec -it "${pod_name}" -- /bin/bash
}

echo "SSH client"
ssh_destination="${ssh_ARGV[0]}"

case "${ssh_destination}" in
    www|magento)
        echo "ssh to www.magento2.localhost"
        container="$(kubectl get pods | grep -ohE 'magento2-www-[a-z0-9\-]+')"
        echo "ssh to ${container}"
        #loginToPodContainer "${container}" "${container}"
        kubectl exec -it "${container}" -- sh
        ;;
    php-fpm) 
        container="$(kubectl get pods | grep -ohE 'magento2-www-[a-z0-9\-]+')"
        echo "ssh to ${container}"
        kubectl exec -it "${container}" -- sh
        ;;
    cli) ;;
    redis)
        echo "ssh to www.magento2.localhost"
        ;;
    db)
        echo "ssh to mariadb.magento2.localhost"
        container="$(kubectl get pods | grep -ohE 'magento2-mariadb-[a-z0-9\-]+')"
        echo "ssh to ${container}"
        loginToPodContainer "${container}" "${container}"
        ;;

    elasticsearch)
        echo "ssh to elasticsearch.magento2.localhost"
        ;;

    minikube)
        echo "ssh to minikube container"
        minikube ssh
        ;;
    *)
        echo "unknow"
esac
