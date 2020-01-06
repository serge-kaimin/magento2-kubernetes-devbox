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
source "${devbox_dir}/scripts/bash-parameters-parsing.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/functions.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/host/parse_yaml_to_variables.sh"
#parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_"
#eval "$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"

# TODO load environments etc/env/[Devbox_environment[n]] as Environment_[Devbox_environment[n]
#

#host_os="$(bash "${devbox_dir}/scripts/host/get_host_os.sh")"

# shellcheck disable=SC2034
Arg_parser_prefix="Environment_"
# shellcheck disable=SC2046
eval $(parse_params "${@}")

# shellcheck disable=SC2154
function environmen_run() {
  local command="${Environment_ARGV[0]}"
  local command_args=""
  local command_run=""
  local command_path="${devbox_dir}/bin/environment/${command}.bash"
  command_args=$(local IFS=" "; echo "${Environment_ARGV[@]}" | cut -d' ' -f2-)
  command_options="$(local IFS=" "; echo "${Environment_ARGO[@]}") $(local IFS=" "; echo "${Environment_ARGN[@]}")"
  command_run="export Devbox_WORKDIR=${devbox_dir}; ${command_path} ${command_args} ${command_options}"
  case ${command} in
    create|update-check|show|versions|init|list|get|status) 
        eval "${command_run}"
        ;;
    *) 
      echo "not correct command:${command}."
      exit 1 
      ;;
  esac
}

environmen_run

# end of bin/environment.sh