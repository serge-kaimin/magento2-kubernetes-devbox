#!/bin/bash
#
# devbox.sh bash autocompletion for Magento Commerce development environment
#
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @version 0.0.1beta (Jan-01-2020)
# @required bash-completion installed
# @required export $Devbox_WORKDIR=[path] (optional)
# @install sudo ln -s docs/usage/devbox_autocompletion.sh /etc/bash_completion.d/devbox.sh
# @initialize source /etc/bash_completion.d/devbox.sh

_devbox() 
{
    local cur prev opts
    local devbox_commands="help version environment instance ssh magento composer yarn autocompletion"
    local devbox_environment_commands="create init start status stop help versions update-check"
    local devbox_environment_versions="devbox autocompletion bash virtualbox minikube kubeadm helm"
    local devbox_instance_commands="list install update start stop delete help"
    local devbox_instance_install="--name"
    local devbox_yarn="install run add init remove publish self-update upgrade prune policies audit info"
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="--help --verbose --version --debug --force"
    
    #TODO load instances if $Devbox_WORKDIR
    
    #TODO load hosts if $Devbox_WORKDIR

    case ${prev} in
        devbox.sh)
            mapfile -t COMPREPLY < <(compgen -W "${devbox_commands}" -- "${cur}")
            return 0
            ;;
        environment) 
            mapfile -t COMPREPLY < <(compgen -W "${devbox_environment_commands}" -- "${cur}")
            return 0
            ;;
        instance) 
            mapfile -t COMPREPLY < <(compgen -W "${devbox_instance_commands}" -- "${cur}")
            return 0
            ;;
        install)
            #TODO names of instances
            mapfile -t COMPREPLY < <(compgen -W "${devbox_instance_install}" -- "${cur}")

            return 0
            ;;
        versions)
            mapfile -t COMPREPLY < <(compgen -W "${devbox_environment_versions}" -- "${cur}")
            return 0
            ;;
        autocompletion)
            mapfile -t COMPREPLY < <(compgen -W "bash" -- "${cur}")
            return 0
            ;;
        yarn)
            #TODO include names from config
            mapfile -t COMPREPLY < <(compgen -W "${devbox_yarn}" -- "${cur}")
            return 0
            ;;
    esac


    case ${cur} in
        *) 
            #COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            mapfile -t COMPREPLY < <(compgen -W "${opts}" -- "${cur}")
            return 0
            ;;
    esac

  #  if [[ ${cur} == -* ]] ; then
  #      COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  #      return 0
  #  fi
}

complete -F _devbox devbox.sh