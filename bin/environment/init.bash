#!/usr/bin/env bash
#
# Development Environment init script for Magento Commerce 
#
# @Arguments: [] [-f|--force|-v|--verbose|--version|--debug]
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

#config_path=${devbox_dir}/etc/Devbox.yaml

# shellcheck disable=SC1090
source "${devbox_dir}/scripts/bash-parameters-parsing.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/functions.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/host/parse_yaml_to_variables.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/bin/include/common.bash"


eval "$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"

# Print commands and their arguments as they are executed if --debug enabled
[[ -n ${Show_debug} ]] && set -x

## parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_"

#
## init kubernetes
#
environment_kubernetes_init()
{
  echo "Kubernetes: ${Devbox_kubernetes_default}"
  case ${Devbox_kubernetes_default} in
    minikube)
      ${devbox_dir}/bin/environment/kubernetes/minikube-init.bash
      ;;
    kind)
      ${devbox_dir}/bin/environment/kubernetes/kind-init.bash
      ;;
    *)
      echo "Unknown kubernetes: ${Devbox_kubernetes_default}"
      exit 1
      ;; 
  esac
  #TODO some --debug and exit codes
}

#
## init local hosts environment 
#
# naming urls: app.project.localhost
# /etc/hosts/
# .x.x.x. ${url}      #project:=${project}
environment_hosts_init() {
  # Hosts must be configured before cluster is started
  #get list of projects
  echo "List of projects available: ${Devbox_env_projects]}"

  for project in $(echo "${Devbox_env_projects}"); do
    echo "Project:${project}"
  done
  #project_names=$(getInstanceList)
  #if [[ -z ${project_names} ]]; then
  #  project_names="default"
  #fi
  #"${devbox_dir}/scripts/host/configure_etc_hosts.sh"
}

#
## init local hosts environment 
#
environment_nfs_init() {
# TODO check OS
  config_content="$(cat "${config_path}")"
  default_nfs_server_ip_pattern="nfs_server_ip: \"0\.0\.0\.0\""
  if [[ ! ${config_content} =~ ${default_nfs_server_ip_pattern} ]]; then
    status "Custom NFS server IP is already specified in '${config_path}' (${nfs_server_ip})"
  else
    # replace configuration for NFS server
    # get IP for KIND  
    # https://raw.githubusercontent.com/rsp/scripts/master/internalip
    # internalip 8.8.8.8
    nfs_server_ip="$(minikube ip | grep -oh "^[0-9]*\.[0-9]*\.[0-9]*\." | head -1 | awk '{print $1"1"}')"
    status "Saving NFS server IP to '${config_path}' (${nfs_server_ip})"
    sed -i.back "s|${default_nfs_server_ip_pattern}|nfs_server_ip: \"${nfs_server_ip}\"|g" "${config_path}"
    rm -f "${config_path}.back"
  fi
} 

#
## Command init
#
environment_init()
{
  #bash "${devbox_dir}/scripts/host/check_requirements.sh"

  # TODO: test environment
  # TODO: init [name]
  # TODO: init -all
  # TODO get data from Devbox_projects

  #config_path="${devbox_dir}/etc/env/config.yaml"

  #TODO check which kubernetes type to init
  environment_kubernetes_init

  # get list of projects
  echo "List of projects available: ${Devbox_env_projects}"

  for project in $(echo "${Devbox_env_projects}"); do
    project_enabled="Devbox_env_projects_${project}_enabled"
    if  [[ "${!project_enabled}" == "true" ]] ; then
      echo "Project: ${project} - enabled"

      ## clone source to the src/[name]
      Init_project_source=$(get_value_by_name "Devbox_env_project_${project}_source")
      case "${Init_project_source}" in
        git)
          echo "project is configured as git"
          Init_git_url="$(get_value_by_name "Devbox_env_project_${project}_git_url")"
          echo " git url: ${Init_git_url}"
          Init_git_tag="$(get_value_by_name "Devbox_env_project_${project}_git_tag")"
          echo " git tag: ${Init_git_tag}"
          Init_git_branch="--branch ${Init_git_tag}"
          Init_git_option="$(get_value_by_name "Devbox_env_project_${project}_git_option")"
          echo " git option: ${Init_git_option}"
          Init_git_path="${devbox_dir}/src/$(get_value_by_name "Devbox_env_project_${project}_path")"
          echo " directory path: .src/${Init_git_path}/"
          Init_command="git clone ${Init_git_branch} ${Init_git_option} ${Init_git_url} ${Init_git_path}"
          #check if git is already cloned
          if [[ -d "${Init_git_path}/.git"  && ! -n ${Show_verbose} ]] ; then 
            echo "git already cloned to ${Init_git_path}"
            echo "you can initialize with --force option or do manually"
            echo "     cd ${Init_git_path} ; git pull"
            echo ""
          else
            echo "${Init_command}"
            eval "${Init_command}"
          fi
          ;;
        directory) 
          echo "project is configured as directory"
          ;;
        *)  
          echo "wrong source: ${Init_project_source}."
          ;;
      esac
    else
      echo "Projects available: ${project} - disabled in Devbox.yaml. Do not initialize."
    fi
  done

  #ls "${devbox_dir}/etc/env/*"

  # https://stackoverflow.com/questions/13322485/how-to-get-the-primary-ip-address-of-the-local-machine-on-linux-and-os-x
  nfs_server_ip="$("${devbox_dir}/bin/include/internalip.sh")"
  echo "Server's IP=${nfs_server_ip}"
  
  exit 0

  # TODO: Do not clean up environment when '-f' flag was not specified
  bash "${devbox_dir}/scripts/host/k_install_environment.sh"
}

environment_init