#!/usr/bin/env bash
# include file

# make script exit when a command fails.
set -o errexit

# Print commands and their arguments as they are executed if --debug enabled
# shellcheck disable=SC2154
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

#host_os="$(bash "${devbox_dir}/scripts/host/get_host_os.sh")"

#
# TODO function to get values from "[]_$[name]_[]"
#
function get_value_by_name () {
    local var_path="$1"
    echo "${!var_path}"
}

#
## Function to test version is greater than min
# @params <version> <min_version> [<max_version>]
#
#
# @result 0  : ok
# @result 1  : need upgrade
# @result 2  : need downgrade
# @result 99 : wrong version format

function is_version_above_min() 
{
    local result="0"
    local InstalledVersion="$1"
    local minversion="$2"
    local maxversion="$3"
    local version_below_min=1
    local version_above_max=0

    # TODO if no max provided, do not check
    [[ -n $3 ]] && version_above_max=1

    if [[ $InstalledVersion =~ ^([v0-9]+\.?)+$ ]]; then
        # shellcheck disable=SC2206
        l=(${InstalledVersion//./ })
        # shellcheck disable=SC2206
        r=(${minversion//./ })
        # shellcheck disable=SC2206
        m=(${maxversion//./ })
        s=${#l[@]}
        [[ ${#r[@]} -gt ${#l[@]} ]] && s=${#r[@]}

        for i in $(seq 0 $((s - 1))); do
            if [[ ${version_below_min} -eq 1 ]] ; then
                #echo "Installed ${l[$i]} > -gt Test ${r[$i]}?"
                [[ ${l[$i]} -gt ${r[$i]} ]] && version_below_min=1 # version > min version.
                [[ ${l[$i]} -lt ${r[$i]} ]] && version_below_min=0 # version < min version.
            fi
            if [[ ${version_above_max} -eq 0 ]] ; then
                [[ ! ${l[$i]} -gt ${m[$i]} ]] && version_above_max=1 # version <= max version.
            fi
        done
        
        #TODO check if 3rd arg provided
        version_above_max=2
        [[ ${version_below_min} -eq 0 ]] && result="1"
        [[ ${version_above_max} -eq 0 ]] && result="2"
    else
        result="99" # Invalid version number
    fi
    echo "${result}" 
}