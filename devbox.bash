#!/usr/bin/env bash
#
# devbox tool to manage Magento Commerce development environment
#
# @Arguments: [environment|instance|ssh|magento|composer|yarn|version|get|set|show] [--force|--verbose|--version|--help]
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @version 0.0.3beta (Jan-02-2020)
# @source https://github.com/serge-kaimin/magento2-kubernetes-devbox
# shellcheck disable=SC2154
# shellcheck disable=SC1090

# make script exit when a command fails.
set -o errexit

#
## Change workdir if $Devbox_WORKDIR
#
[ -z "${Devbox_WORKDIR}" ] && devbox_dir=$PWD || devbox_dir=${Devbox_WORKDIR}

Devbox_version=$(grep @version -m 1 "${devbox_dir}"/devbox.bash | tr -s ' ' | cut -d ' ' -f 3)

# TODO Load etc/Devbox.yaml

#
## Parse shell comands, sub-comands, arguments, anf flags
# TODO: move it to external script and change values of assigned options from array Devbox_name="name of devbox"
source "${devbox_dir}/scripts/bash-parameters-parsing.sh"
#TODO Remove: $Arg_parser_prefix AND add parsing argument: -pRfx=Devbox_
#Devbox_args=$@
# shellcheck disable=SC2034
Arg_parser_prefix="Devbox_"
# shellcheck disable=SC2046
eval $(parse_params "${@}" )
#echo $(parse_params "${@}" )
#echo "Devbox_ARGV:${Devbox_ARGV[1]}"

#
## Enable verbose flag --verbose enabled
#
if [[ -n ${Devbox_verbose} ]]; 
then
    echo "Verbose mode enabled"
    if [[ -n ${Devbox_WORKDIR} ]];
    then
        echo "devbox.bash WORKDIR set to: ${Devbox_WORKDIR}/"
    fi
    # shellcheck disable=SC2046
    parse_params "$@"
fi

# TODO check if environment is initialized, then set to 1
Devbox_initialized=""

#
# Print commands and their arguments as they are executed if --debug enabled
#
if [[ -n ${Devbox_debug} ]]
then
    set -x
fi

#
## Show devbox main help
#
devbox_help ()
{
    echo ""
    echo ""
    if [[ -n ${Devbox_initialized} ]]; then
        cat "${devbox_dir}/docs/usage/devbox.txt"
    else
        cat "${devbox_dir}/docs/usage/devbox-short.txt"
    fi
}

#
## Display version and release notes of devbox.bash
#
devbox_version () 
{
    if [[ -n ${Devbox_short} ]]; then
        # Display just version number
        echo "${Devbox_version}"
    else
        # Display full version details
        echo "devbox.bash, version: ${Devbox_version}"
        echo "Open Software License (OSL 3.0) [https://opensource.org/licenses/OSL-3.0]."
        echo ""
        echo "This is free software; you are free to change and redistribute it."
        echo "There is NO WARRANTY, to the extent permitted by law."
        if [ -n "${Devbox_verbose}" ]; 
        then
            # Show release notes if --verbose
            cat "${devbox_dir}/docs/usage/devbox-release-notes.txt"
        fi
        echo ""
    fi
}

#
## Command: instance
#
devbox_instance ()
{
    case ${Devbox_ARGV[1]} in 
        list) 
            echo "List of instances"
            "${devbox_dir}/bin/environment.sh list"
            ;;
        init) 
            echo "Init instance"
            # TODO add instance name, and verbose if specified
            "${devbox_dir}/bin/environment.sh init"
            ;;
        start) 
            echo "Start!"
            #TODO add instance name, and verbose if specified
            "${devbox_dir}/bin/environment.sh start"
            ;;
        status) echo "Status!" ;;
        stop) echo "Stop!" ;;
        delete) echo "Delete!" ;;
        *) 
            echo ""
            echo "Error: unknown command"
            echo "Run './devbox.bash help' for usage."
            echo ""
        ;;
    esac

}

#
# route first comand to functions to parse subcomands and arguments
#
function devbox_run() {
    local command="${Devbox_ARGV[0]}"
    local command_path="${devbox_dir}/bin/${command}.bash"
    local command_args=""
    command_args="$(local IFS=" "; echo "${Devbox_ARGV[@]}" | cut -d' ' -f2-)"
    local command_options=""
    command_options="$(local IFS=" "; echo "${Devbox_ARGO[@]}")"
    #TODO parse Devbox_ARGN for Devbox_, assign variables, and remove them from array
    command_options="$(local IFS=" "; echo "${Devbox_ARGO[@]}") $(local IFS=" "; echo "${Devbox_ARGN[@]}")"
    local comannd_run="export Devbox_WORKDIR=${devbox_dir}; ${command_path} ${command_args} ${command_options}"
    case ${command} in
        help) devbox_help ;;
        version) devbox_version ;;
        instance) devbox_instance ;;
        ide|environment|yarn|composer|ssh|magento)
            #echo "${comannd_path}"
            #if [ -f "${comannd_path}")" ]; then 
                eval "${comannd_run}"
            #else
            #    echo "bash script does mot exist: ${comannd_path}."
            #fi
            ;;
        autocompletion)
            cat "${devbox_dir}/docs/usage/devbox_autocompletion.sh"
            if [[ -n ${Devbox_verbose} ]]; 
            then
                # print instruction to setup bash autocompletion if --verbose
                echo ""
                echo "---------------------------------------------------------------------"
                echo "To setup bash autocompletion for devbox.bash run:"
                echo "  source <(devbox.bash autocompletion bash) "
                echo "or install:"
                echo "  sudo ln -s ${devbox_dir}/docs/usage/devbox_autocompletion.sh /etc/bash_completion.d/devbox"
                echo "  (you need to logout and login after installation)"
            fi
            ;;
        *) 
            echo "command not recognized: ${command}"
            devbox_help 
            ;;
esac
}

devbox_run

# devbox script end
