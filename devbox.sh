#!/bin/bash

# devbox tool to manage Magento Commerce development environment
#
# @Arguments: [environment|instance|ssh|magento|composer|version|get|set|show] [--force|--verbose|--version|--help]
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @version 0.0.1beta (Jan-01-2020)
# @source https://github.com/serge-kaimin/magento2-kubernetes-devbox

# make script exit when a command fails.
set -o errexit

#
## Change workdir if $Devbox_WORKDIR
#
# shellcheck disable=SC2154
[ -z "${Devbox_WORKDIR}" ] && devbox_dir=$PWD || devbox_dir=${Devbox_WORKDIR}

Devbox_version=$(grep @version -m 1 "${devbox_dir}"/devbox.sh | tr -s ' ' | cut -d ' ' -f 3)

# TODO Load etc/Devbox.yaml

#
## Parse shell comands, sub-comands, arguments, anf flags
# TODO: move it to external script and change values of assigned options from array Devbox_name="name of devbox"
# shellcheck disable=SC1090
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
# shellcheck disable=SC2154
if [[ -n ${Devbox_verbose} ]]; 
then
    echo "Verbose mode enabled"
    if [[ -n ${Devbox_WORKDIR} ]];
    then
        echo "devbox.sh WORKDIR set to: ${Devbox_WORKDIR}/"
    fi
    # shellcheck disable=SC2046
    parse_params "$@"
fi

# TODO check if environment is initialized, then set to 1
Devbox_initialized=""

#
# Print commands and their arguments as they are executed if --debug enabled
#
# shellcheck disable=SC2154
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
## Display version and release notes of devbox.sh
#
devbox_version () 
{
    # shellcheck disable=SC2154
    if [[ -n ${Devbox_short} ]]; then
        # Display just version number
        echo "${Devbox_version}"
    else
        # Display full version details
        echo "devbox.sh, version: ${Devbox_version}"
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
## Command: environment
#
devbox_environment ()
{
    #TODO check if all args are valid

    #
    # if --verbose enabled pass --verbose to sub-comands arguments
    local comandargs=""
    if [ -n "${Devbox_verbose}" ]; 
    then
        echo "run command: environment"
        # shellcheck disable=SC2154
        echo "subcomand: ${Devbox_ARGV[1]}"
        comandargs="${comandargs} --verbose"
    fi

    #
    # if -help enabled add --help to comand arguments
    #
    # shellcheck disable=SC2154
    if [ -n "${Devbox_help}" ]; 
    then
        comandargs="${comandargs} --help"
    fi

    #TODO shift args array and pass to the environment script or not
    case ${Devbox_ARGV[1]} in 
        create)
            # TODO check if no other wrong args passed
            # TODO check if instance name ${Devbox_ARGV[2] already exist
            "${devbox_dir}"/bin/environment.sh create "${Devbox_ARGV[2]}" "${comandargs}"
            ;;
        init)
            # TODO check if instance name ${Devbox_ARGV[2] exist
            "${devbox_dir}"/bin/environment.sh init "${Devbox_ARGV[2]}" "${comandargs}"
            ;;
        start) 
            "${devbox_dir}"/bin/environment.sh start "${Devbox_ARGV[2]}" "${comandargs}"
            ;;
        status) 
            "${devbox_dir}"/bin/environment.sh status "${Devbox_ARGV[2]}" "${comandargs}"
            ;;
        stop)  
            "${devbox_dir}"/bin/environment.sh stop "${Devbox_ARGV[2]}" "${comandargs}"
            ;;
        delete) 
            "${devbox_dir}"/bin/environment.sh delete "${Devbox_ARGV[2]}" "${comandargs}"
            ;;
        versions)
            # TODO check if ARGV[2] in array=(os,devbox,virtualbox,minikube,helm)
            "${devbox_dir}"/bin/environment.sh versions "${Devbox_ARGV[2]}" "${comandargs}"
            ;;
        show)
            # TODO check if ARGV[2] in array=(os,devbox,virtualbox,minikube,helm)
            "${devbox_dir}"/bin/environment.sh show "${Devbox_ARGV[2]}" "${comandargs}"
            ;;
        update-check)
            # TODO check if ARGV[2] in array=(os,devbox,virtualbox,minikube,helm)
            "${devbox_dir}"/bin/environment.sh versions "${Devbox_ARGV[2]}" "${comandargs}"
            ;;
        *) 
            echo ""
            cat "${devbox_dir}/docs/usage/devbox-environment.txt"
            echo ""
            ;;
    esac
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
            echo "Run './devbox.sh help' for usage."
            echo ""
        ;;
    esac

}

#
## Command: magento
#
devbox_magento ()
{
    #TODO check arguments
    "${devbox_dir}"/bin/magento "${Devbox_ARGV[1]}"
}

#
# route first comand to functions to parse subcomands and arguments
#
case ${Devbox_ARGV[0]} in
    help) devbox_help ;;
    version) devbox_version ;;
    environment) devbox_environment ;;
    instance) devbox_instance ;;
    magento) devbox_magento ;;
    ssh)
        #TODO check ${Devbox_ARGV[1]} is existing container
        "${devbox_dir}"/bin/ssh "${Devbox_ARGV[1]}"
        ;;
    composer) 
        "${devbox_dir}"/bin/composer "${Devbox_ARGV[1]}"
        ;;
    get) 
        "${devbox_dir}"/bin/get "${Devbox_ARGV[1]}" 
        ;;
    set) 
        "${devbox_dir}"/bin/set "${Devbox_ARGV[1]}" "${Devbox_ARGV[2]}"
        ;;
    show) 
        "${devbox_dir}"/bin/show "${Devbox_ARGV[1]}"
        ;;
    autocompletion)
        cat "${devbox_dir}/docs/usage/devbox_autocompletion.sh"
        if [[ -n ${Devbox_verbose} ]]; 
        then
            # print instruction to setup bash autocompletion if --verbose
            echo ""
            echo "---------------------------------------------------------------------"
            echo "To setup bash autocompletion for devbox.sh run:"
            echo "  source <(devbox.sh autocompletion bash) "
            echo "or install:"
            echo "  sudo ln -s ${devbox_dir}/docs/usage/devbox_autocompletion.sh /etc/bash_completion.d/devbox"
            echo "  (you need to logout and login after installation)"
        fi
        ;;
    *) 
        echo "no comand recognized"
        devbox_help 
        ;;
esac

# devbox script end
