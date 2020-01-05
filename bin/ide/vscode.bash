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
Arg_parser_prefix="Code_" 
eval "$(parse_params "${@}")"
[[ -n ${Code_verbose} ]] && parse_params "${@}"

#TODO check if code is installed ${Devbox_ide_vscode_run}

# print --version and exit
if [[ -n ${Code_version} ]]; then
    #TODO run comand/path from ${Devbox_ide_vscode_run}
    InstalledVersion="$(code --version | head -1)"
    echo "${InstalledVersion}"
    result=$(is_version_above_min "${InstalledVersion}" "1.4.0" )
    case $result in
        "0") [[ -n ${Code_verbose} ]] && echo "Version is OK" ;;
        "1") [[ -n ${Code_verbose} ]] && echo "Version is above min. You need to uprade" ;;
        "2") [[ -n ${Code_verbose} ]] &&echo "Version is below max. You need to downgrade";;
        *) [[ -n ${Code_verbose} ]] && echo "r:$result"
    esac
    exit 0
fi

##TODO validate version

if [[ -n ${Code_init} ]]; then
  command_args="$(IFS=" "; echo "${Code_ARGV[@]}" | cut -d' ' -f2-)"
  #command_options="$(IFS=" "; echo "${IDE_ARGO[@]}")"
  command_options="$(IFS=" "; echo "${Code_ARGO[@]}") $(IFS=" "; echo "${Code_ARGN[@]}")"
  command_path="${devbox_dir}/bin/ide/vscode/init.bash"
  Code_init_path="."
  Code_init_path="${devbox_dir}/etc/ide/vscode/"
  command_run="${command_path} ${Code_init_path} ${command_args} ${command_options}"
  eval "${command_run}"
  exit 0
fi

#TODO check if -instance=<name> supplied then run code from specific directory
if [[ -n ${Code_clean} ]]; then
    echo "c:${command_run}"
    eval "${command_run}"    
    exit 0
fi

#TODO check Devbox_ide_vscode_install_custom if user_data_dir to custom
#
## setup path "code ." or custom "code ./magento2/"
#
Code_path_arg=${Code_ARGV[0]}
if [[ -n ${Code_path_arg} ]]; then
    #Code_path="${devbox_dir}${Code_path_arg}"
    #TODO validate path and check if src is ok
    Code_path="src/${Code_path_arg}"
else
    echo "path should be provided, for example:"
    echo "devbox ide code ."
    exit 1
fi

#TODO aliases: code ~/.bash_profile https://flaviocopes.com/how-to-set-alias-shell/

#
## Start VS Code
#
Code_userdata="--user-data-dir ${devbox_dir}/etc/ide/vscode/default.userdata/"
#TODO custom --user-data-dir for magento2 and venia ${devbox_dir}/etc/ide/vscode/venia.userdata/
command="${command_aliases} ${Devbox_ide_vscode_run} ${Code_userdata} ${Code_path}"
[[ -n ${Code_verbose} ]] && echo "Run IDE: ${command}"
eval "${command}"
