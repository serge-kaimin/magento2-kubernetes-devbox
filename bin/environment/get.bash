#!/usr/bin/env bash
#
# Get parameters of current Magento Commerce devbox environment
#
# usage: 
#
#   devbox environment get [instance_name] [--all] [--verbose] [--debug] [--devbox]
#   devbox environment get instance_name [name={parameter name}"]
#
# @Arguments: [environment name] .. [environment name]
# @Arguments: [options]
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @source https://github.com/serge-kaimin/magento2-kubernetes-devbox
# shellcheck disable=SC2154
# shellcheck disable=SC1090

[ -z "${Devbox_WORKDIR}" ] && devbox_dir=$PWD || devbox_dir=${Devbox_WORKDIR}

source "${devbox_dir}/scripts/host/parse_yaml_to_variables.sh"
#source "${devbox_dir}/scripts/functions.sh"
parsed_yaml="$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"
eval "${parsed_yaml}"

source "${devbox_dir}/scripts/bash-parameters-parsing.sh"
# shellcheck disable=SC2034
Arg_parser_prefix="Show_"
eval "$(parse_params "${@}" )"

# Print commands and their arguments as they are executed if --debug enabled
[[ -n ${Show_debug} ]] && set -x

if [[ -n ${Show_verbose} ]]; then
    echo "Parsed yaml:"
    echo "${parsed_yaml}"
    echo "Parsed args:"
    parse_params "${@}"
fi

#
## Show configuration for devbox yaml
# 
function show_devbox() 
{
    local parsed_yaml

    [[ -n ${Show_verbose} ]] && echo "Show configuration --devbox"
    
    parsed_yaml="$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "Devbox_")"
    echo "${parsed_yaml}"
}

is_instance_enabled()
{
    local name=$1
}

#
## Show insance [name] YAML configuration
#
function show_instance() 
{
    #TODO show overrides in verbose mode
    # shellcheck disable=SC2124
    local gets=${Show_ARGN[@]}
    local name=$1
    local var_path="Devbox_env_${name}_path" 
    local path="${!var_path}"
    local chart_path="${devbox_dir}/etc/helm/${path}/Chart.yaml"
    local values_path="${devbox_dir}/etc/helm/${path}/values.yaml"
    local var_enabled="Devbox_env_${name}_enabled"
    local instance_enabled="${!var_enabled}"

    [[ -n ${Show_verbose} ]] && echo "Instance name: ${name}"
    [[ -n ${Show_verbose} ]] && echo "Instance enabled: ${var_enabled}=${instance_enabled}"

    eval "$(parse_yaml "${chart_path}" "Environment_env_${instance}_")"
    parse_yaml "${chart_path}" "Environment_env_${instance}_"

    if [[ -n ${gets} ]]; then
        # shellcheck disable=SC2116
        for item in $(echo "${gets}"); do
            #echo "item: ${item}"
            #[[ "${item##*"--get="}"]] || echo 'Substring found!'
            if [[ $item == "--get"* ]]; then
                item_name=${item:6}
                get_var="Environment_env_${name}_${item_name}"
                get_name="${!get_var}"
                if [[ -n ${Show_verbose} ]]; 
                    then echo "${get_var}:${get_name}"
                    else echo "${get_name}"; fi
                exit 0
            fi
        done
    fi

    #env_path="${devbox_dir}/etc/env/${name}.yaml"
    #${devbox_dir}/etc/env/${name}.yaml
    
    #TODO check if instance not enabled
    if [[ -f ${chart_path} ]]; then
        [[ -n ${Show_verbose} ]] && echo "Helm file loaded: ${chart_path}"
        parse_yaml "${chart_path}" "Helm_${name}_chart_"

        if [[ -f ${values_path} ]]; then
            [[ -n ${Show_verbose} ]] && echo "Values file loaded: ${chart_path}"
            parse_yaml "${values_path}" "Values_${name}_values_"
        else
            [[ -n ${Show_verbose} ]] && echo "file does not exist: ${values_path}"
        fi
    else
        [[ -n ${Show_dverbose} ]] && echo "file does not exist: ${chart_path}"
    fi
}

function show_instances() 
{
    # shellcheck disable=SC2124
    local instances=${Devbox_env_instances[@]}
    [[ -n ${Show_verbose} ]] && echo "Available environment: ${instances}"
    # shellcheck disable=SC2116
    for instance in $(echo "${instances}"); do
        show_instance "${instance}"
    done
}

#
# Main 
#
#[[ -n ${Show_all} ]] && show_devbox ; show_instances ; exit 0

[[ -n ${Show_devbox} ]] && show_devbox

instance_name=${Show_ARGV[0]}
if [[ -n ${instance_name} ]]; then
    [[ -n ${Show_verbose} ]] && echo "Ags supplied: ${Show_ARGV[*]}"

    names="${Show_ARGV[*]}"
    # shellcheck disable=SC2116
    for name in $(echo "${names}"); do show_instance "${name}" ; done
fi
