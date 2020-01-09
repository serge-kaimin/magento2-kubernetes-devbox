#!/usr/bin/env bash
#
# Development Environment IDE for Magento Commerce 
#
# @Arguments: <ide-name> [<path>] [--init][--force|--verbose|--version|--debug]
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @source https://github.com/serge-kaimin/magento2-kubernetes-devbox
# shellcheck disable=SC2154
# shellcheck disable=SC1090

#
## Change workdir if $Devbox_WORKDIR and include common
# shellcheck disable=SC2154
[ -z "${Devbox_WORKDIR}" ] && devbox_dir=$PWD || devbox_dir=${Devbox_WORKDIR}
. "${devbox_dir}/bin/include/common.bash"

eval "$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"

# shellcheck disable=SC2034
Arg_parser_prefix="Versions_" 
eval "$(parse_params "${@}")"
[[ -n ${Code_verbose} ]] && parse_params "${@}"

environment_versions()
{
  #TODO check if environment versions virtualbox
  Devbox_version=$(grep @version -m 1 "${devbox_dir}"/devbox.bash | tr -s ' ' | cut -d ' ' -f 3)

  if [ -f /etc/bash_completion.d/devbox.bash ]
  then
    Devbox_autocomletion=$(grep @version /etc/bash_completion.d/devbox.bash | tr -s ' ' | cut -d ' ' -f 3)
  else
    Devbox_autocomletion="not installed"
  fi 

  Environment_bash=$(bash --version | grep "GNU bash" | tr -s ' ' | cut -d ' ' -f 4)

  #TODO check if virtualbox not installed
  Environment_virtualbox=$(vboxmanage --version)
  #TODO check if kubeadm not installed
  Environment_kubeadm=$(kubeadm version -o short)
  Environment_minikube=$(minikube version | tr -s ' ' | cut -d ' ' -f 3)
  #minikube kubectl -- --version
  
  # shellcheck disable=SC2154
  case ${environment_ARGV[1]} in
    devbox) 
      echo "${Devbox_version}"
      ;;
    virtualbox)
      echo "${Environment_virtualbox}"
      ;;
    minikube)
      #TODO get short version
      echo "${Environment_minikube}"
      ;;
    autocompletion)
      echo "${Devbox_autocomletion}"
      ;;
    kubeadm)  
      echo "${Environment_kubeadm}"
      ;;
    *)
      #TODO check if not installed, mark red 
      echo "devbox.bash script version: ${Devbox_version}"
      #TODO check if Devbox_version != Devbox_autocomletion, mark yelow
      echo "devbox.bash autocompletion: ${Devbox_autocomletion}"
      echo "devbox.bash workdir path: ${Devbox_WORKDIR}"
      echo "BASH version: ${Environment_bash}"
      echo "OS: ${host_os}"
      echo "Linux kernel version: $(uname -r)"
      #Environment_description="$(lsb_release -a | grep Description)"
      #echo ${Environment_description}
      hostnamectl
      echo "virtualbox: ${Environment_virtualbox}"
      echo "Minikube: ${Environment_minikube}"
      #TODO kubectl version
      echo "kubeadm version: ${Environment_kubeadm}"
      #TODO helm version
      ;;
  esac
}

environment_versions

# devbox script end
