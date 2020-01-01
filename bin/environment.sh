#!/bin/bash

# Development Environment management tool for Magento Commerce 
#
# @Arguments: [create|init|delete|start|stop|test|ssh|cli|magento|composer|versions] [-f|--force|-v|--verbose|--version|--debug]
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @version v0.0.1beta (Dec-31-2019)
# @source https://github.com/serge-kaimin/magento2-kubernetes-devbox

#
## Change workdir if $Devbox_WORKDIR
# shellcheck disable=SC2154
[ -z "${Devbox_WORKDIR}" ] && devbox_dir=$PWD || devbox_dir=${Devbox_WORKDIR}

if [ -d "./../bin/" ] && [ -n "${Devbox_WORKDIR}" ]; then
    echo "${Devbox_WORKDIR}"
    echo "script environment.sh should not run from bin/ directory"
    echo "current directory is: ${PWD}"
    echo ""
    echo "should you change directory"
    echo "  cd ../bin | bin/environment.sh"
    echo "        or" 
    echo "  export Devbox_WORKDIR=[path to devbox.sh WORKDIR]"
    exit 1
fi

# shellcheck disable=SC1090
source "${devbox_dir}/scripts/bash-parameters-parsing.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/functions.sh"
host_os="$(bash "${devbox_dir}/scripts/host/get_host_os.sh")"

# Environment_args=$@
# shellcheck disable=SC2034
Arg_parser_prefix="Environment_"
# shellcheck disable=SC2046
eval $(parse_params "${@}")

#
## Command create
#
environment_create()
{
    # TODO: test environment
    # TODO: if no environment ready propose to do: environment create
    echo "Create!"
}

#
## Command init
#
environment_init()
{
    # TODO: test environment
    # TODO: if no environment ready propose to do: environment create
    echo "Init!"
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

    case ${environment_ARGV[1]} in
        devbox) 
            echo "${Devbox_version}"
            ;;
        virtualbox)
            echo "${Environment_virtualbox}"
            ;;
        minikube)
            #TODO get short version
            minikube version | tr -s ' ' | cut -d ' ' -f 3
            ;;
        autocompletion)
            echo "${Devbox_autocomletion}"
            ;;
        *)
            echo "devbox.sh script version: ${Devbox_version}"
            echo "devbox.sh autocompletion: ${Devbox_autocomletion}"
            echo "devbox.sh workdir path: ${Devbox_WORKDIR}"
            echo "BASH version: ${Environment_bash}"
            echo "OS: ${host_os}"
            echo "virtualbox: ${environment_virtualbox}"
            minikube version
            #TODO kubectl version
            echo "kubeadm version: $(kubeadm version -o short)"
            #TODO helm version
         ;;
    esac
}

environment_update_check ()
{
    echo "Updates check!"
    #TODO check if latest devbox available
    
    #check if devbox

}

case ${Environment_ARGV[0]} in
    create) environment_create ;;
    init) environment_init ;;
    get) echo "Get!" ;;
    set) echo "Set!" ;;
    show) echo "Show!" ;;
    status) echo "Status!" ;;
    versions) environment_versions ;;
    update_check) environment_update_check ;;
    *) 
        echo "not correct command"
        exit 1 
        ;;
esac

# end of bin/environment.sh