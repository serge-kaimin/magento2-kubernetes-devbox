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
eval "$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"

# shellcheck disable=SC2034
Arg_parser_prefix="Minikube_"
eval "$(parse_params "${@}" )"

# Print commands and their arguments as they are executed if --debug enabled
[[ -n ${Minikube_debug} ]] && set -x

#TODO check OS and put ./devbox/os

minikube_version=$("${devbox_dir}/devbox.bash" "environment" "versions" "minikube")
if [ -f "${devbox_dir}/.devbox/minikube" ] ; then
  previous_minikube=$(cat "${devbox_dir}"/.devbox/minikube)
  [[ -n ${Minikube_verbose} ]] && echo "Minikube version on previous run: ${previous_minikube}"
  # TODO check if version changed after upgrade
  if [[ -n ${Minikube_force} ]] ; then 
    minikube stop 2> >(logError) | {
      while IFS= read -r line; do
        filterDevboxOutput "${line}"
        lastline="${line}"
      done
      filterDevboxOutput "${lastline}"
    }
    rm "${devbox_dir}/.devbox/minikube"
  else
  cat << EOF

minicube already initialized
use devbox.bash environment start
or devbox.bash environment init --force to delete minicube

EOF
    exit 1
  fi

fi
echo "minikube: ${minikube_version}"
echo "${minikube_version}" > "${devbox_dir}/.devbox/minikube"

if [[ $(isMinikubeRunning) -eq 1 ]]; then
  echo "Minikube is running"
  if [[ -n ${Minikube_force} ]] ; then 
    minikube stop 2> >(logError) | {
      while IFS= read -r line; do
        filterDevboxOutput "${line}"
        lastline="${line}"
      done
      filterDevboxOutput "${lastline}"
    }
    rm "${devbox_dir}/.devbox/minikube"
  else
    cat << EOF

minicube already running 
use devbox.bash environment stop 
or devbox.bash environment init --force to delete minicube and reinitialize

EOF
    exit 1
  fi
fi

status "Starting minikube"

exit 1

##TODO check if --force
if [[ ! $(isMinikubeRunning) -eq 1 ]]; then
    #TODO validate minikube version
    : "${Devbox_kubernetes_minikube_cpus:="2"}"
    : "${Devbox_kubernetes_minikube_memory:="2048"}"
    # TODO --kubernetes-version=v1.x.x

    minikube config set cpus "${Devbox_kubernetes_minikube_cpus}"
    minikube config set memory "${Devbox_kubernetes_minikube_memory}"
    minikube config set vm-driver "${Devbox_kubernetes_minikube_vm_driver}"

    #TODO minikube config set disk-size 20000MB
    #minikube config set kubernetes-version v1.15.6  

    minikube_command="minikube start --cpus=${Devbox_kubernetes_minikube_cpus} --memory=${Devbox_kubernetes_minikube_memory} --vm-driver=${Devbox_kubernetes_minikube_vm_driver}"
    echo "${minikube_command}"
    eval "${minikube_command}"

    # enable addons from configuration
    addons="${Devbox_kubernetes_minikube_addons_enable}"
    for addon in ${addons}; do
      #TODO escape quotes
      echo "enable addon: [${addon}]"
      minikube addons enable "${addon}"
    done

    # Build images in minikube environment
    devbox.bash environment build

  else 
    echo "Minikube is runnig stop it"
    exit 1
  fi
