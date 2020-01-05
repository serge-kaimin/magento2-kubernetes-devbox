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

if [ -d "./../bin/" ] && [ -n "${Devbox_WORKDIR}" ]; then
  #echo "${Devbox_WORKDIR}"
  echo "script environment.sh should not run from bin/ directory"
  echo "current directory is: ${PWD}"
  echo ""
  echo "should you change directory"
  echo "  cd ../bin | bin/environment.sh"
  echo "        or" 
  echo "  export Devbox_WORKDIR=[path to your devbox.sh WORKDIR]"
  exit 1
fi

# shellcheck disable=SC1090
source "${devbox_dir}/scripts/bash-parameters-parsing.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/functions.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/host/parse_yaml_to_variables.sh"
#parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_"
#eval "$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"

# TODO load environments etc/env/[Devbox_environment[n]] as Environment_[Devbox_environment[n]
#


host_os="$(bash "${devbox_dir}/scripts/host/get_host_os.sh")"
# Environment_args=$@
# Load arguments, including overrides on Environment_
# shellcheck disable=SC2034
Arg_parser_prefix="Environment_"
# shellcheck disable=SC2046
#echo $(parse_params "${@}")
eval $(parse_params "${@}")

#
## Command create
#
environment_list()
{
  # shellcheck disable=SC2154
  if [[ -n ${Environment_verbose} ]]
  then
    status "List devbox environment"
  fi
  echo "magento2"
  echo "pwa-studio"
}


environment_create()
{
  # TODO: test environment
  #status "Create new devbox environment"
  # TODO: get envi
  local Create_name
  local Create_source
  if [[ -n ${Environment_verbose} ]]
  then
    echo "Enter the name of new environment. Environment name should include letters and digits."
    echo "environment configuration to be stored in etc/env/[name].yaml"
  fi
  read -p -r "Environment name:" Create_name
  echo "New environment to be created is: ${Create_name}"
  #TODO validate name
  #TODO check if environment with entered name already exist

  if [[ -n ${Environment_verbose} ]]
  then
    #TODO color
    echo "Environment source could be \"directory\" or git paths."
    echo "if you enter \"directory\" as source, appropriate directory should already to be exist: etc/helm/${Create_name}/"
    echo "if you will enter git path to, script would download it using git"
  fi
  read -p -r "Environment source:" Create_source
  if [ "${Create_source}" == "directory" ]; then
    if [ ! -d "etc/helm/${Create_source}" ]; then
      echo "Directory does not exist: etc/helm/${Create_source}"
      echo "Create directory and configuration files before devbox environment create"
      exit 1
    fi
    #TODO  validate configuration files
    echo "Source directory validated: ${Create_source}"
  else
    #TODO validate source path
    echo "git pull ${Create_source}"
    # git pull to etc/helm/${Create_name}/
  fi
}

#
## Command init
#
environment_init()
{
  bash "${devbox_dir}/scripts/host/check_requirements.sh"

  # TODO: test environment
  # TODO: init [name]
  # TODO: init -all
  # TODO get data from Devbox_instance 
  config_path="${devbox_dir}/etc/env/config.yaml"
  
  #TODO check that it in create 
  if [[ ! -f "${config_path}" ]];
  then
    status "No environment configuration found."
    echo "Run: devbox.sh create"
    #exit 0
  #  status "Initializing etc/env/config.yaml using defaults from etc/env/config.yaml.dist"
  #  cp "${devbox_dir}/etc/env/config.yaml.dist" "${config_path}"
  fi

  status "Initializing devbox"

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
  fi

  # 
  config_content="$(cat "${config_path}")"
  default_nfs_server_ip_pattern="nfs_server_ip: \"0\.0\.0\.0\""
  if [[ ! ${config_content} =~ ${default_nfs_server_ip_pattern} ]]; then
    status "Custom NFS server IP is already specified in '${config_path}' (${nfs_server_ip})"
  else
    nfs_server_ip="$(minikube ip | grep -oh "^[0-9]*\.[0-9]*\.[0-9]*\." | head -1 | awk '{print $1"1"}')"
    status "Saving NFS server IP to '${config_path}' (${nfs_server_ip})"
    sed -i.back "s|${default_nfs_server_ip_pattern}|nfs_server_ip: \"${nfs_server_ip}\"|g" "${config_path}"
    rm -f "${config_path}.back"
  fi

  # Hosts must be configured before cluster is started
  instance_names=$(getInstanceList)
  if [[ -z ${instance_names} ]]; then
    instance_names="default"
  fi
  bash "${devbox_dir}/scripts/host/configure_etc_hosts.sh"

  # TODO: Do not clean up environment when '-f' flag was not specified
  bash "${devbox_dir}/scripts/host/k_install_environment.sh"

}

environment_clean()
{
  status "Clean up the environmen before initialization"
  force_project_cleaning=0
  #force_instance_cleaning=0
  #force_codebase_cleaning=0
  force_phpstorm_config_cleaning=0

  if [[ $(isMinikubeRunning) -eq 1 ]]; then
    minikube stop 2> >(logError) | {
      while IFS= read -r line; do
        filterDevboxOutput "${line}"
        lastline="${line}"
      done
      filterDevboxOutput "${lastline}"
    }
  fi

  if [[ $(isMinikubeStopped) -eq 1 ]]; then
    minikube delete 2> >(logError) | {
      while IFS= read -r line; do
        filterDevboxOutput "${line}"
        lastline="${line}"
      done
      filterDevboxOutput "${lastline}"
    }
  fi

  cd "${devbox_dir}/log" && mv email/.gitignore email_gitignore.back && rm -rf email && mkdir email && mv email_gitignore.back email/.gitignore
  
  if [[ ${force_project_cleaning} -eq 1 ]] && [[ ${force_phpstorm_config_cleaning} -eq 1 ]]; then
    status "Resetting PhpStorm configuration since '-p' option was used"
    rm -rf "${devbox_dir}/.idea"
  fi
}

environment_versions()
{
  #TODO check if environment versions virtualbox
  Devbox_version=$(grep @version -m 1 "${devbox_dir}"/devbox.sh | tr -s ' ' | cut -d ' ' -f 3)

  if [ -f /etc/bash_completion.d/devbox.sh ]
  then
    Devbox_autocomletion=$(grep @version /etc/bash_completion.d/devbox.sh | tr -s ' ' | cut -d ' ' -f 3)
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
      echo "devbox.sh script version: ${Devbox_version}"
      #TODO check if Devbox_version != Devbox_autocomletion, mark yelow
      echo "devbox.sh autocompletion: ${Devbox_autocomletion}"
      echo "devbox.sh workdir path: ${Devbox_WORKDIR}"
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

# shellcheck disable=SC2154
function environmen_run() {
  local command="${Environment_ARGV[0]}"
  local command_args=""
  local comannd_run=""
  local command_path="${devbox_dir}/bin/environment/${command}.bash"
  command_args=$(local IFS=" "; echo "${Environment_ARGV[@]}" | cut -d' ' -f2-)
  command_options="$(local IFS=" "; echo "${Environment_ARGO[@]}") $(local IFS=" "; echo "${Environment_ARGN[@]}")"
  comannd_run="export Devbox_WORKDIR=${devbox_dir}; ${command_path} ${command_args} ${command_options}"
  case ${command} in
    create) environment_create ;;
    init) environment_init ;;
    list) environment_list ;;
    get) echo "Get!" ;;
    set) echo "Set!" ;;
    update-check|show) 
        eval "${comannd_run}"
        ;;
    status) echo "Status!" ;;
    versions) environment_versions ;;
    *) 
      echo "not correct command:${command}."
      exit 1 
      ;;
  esac
}

environmen_run

# end of bin/environment.sh