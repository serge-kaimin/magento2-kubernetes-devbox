#!/usr/bin/env bash
#
# Initialize Vs Code Development Environment for Magento Commerce 
#
# @Arguments: <path> [<project-name>] [--force|--verbose|--version|--debug]
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
Arg_parser_prefix="Codeinit_"
eval "$(parse_params "${@}")"
[[ -n ${Codeinit_verbose} ]] && parse_params "${@}"

Codeinit_path="${Codeinit_ARGV[0]}"
echo "Init Microsoft Visual Code environment"

[[ -n ${Codeinit_verbose} ]] && echo "--user-data-dir path:${Codeinit_path}"

#TODO check if <project-name> !=code
Code_init_project="${Codeinit_ARGV[1]}"
#TODO check if project != code OR ide
[[ -n ${Code_init_project} ]] && echo "Initialize project: ${Code_init_project}"

#
## Install VS Code extensions
#
Init_user_data_dir="--user-data-dir ${devbox_dir}/etc/ide/vscode/default.userdata/"

echo "TODO: copy .setting.json to ${Code_init_path}/"
if [[ -n ${Devbox_ide_vscode_install_extensions} ]] ; then
    [[ -n ${Codeinit_verbose} ]] && echo "Extensions to install: ${Devbox_ide_vscode_install_extensions}"
    # shellcheck disable=SC2116    
    for item in $(echo "${Devbox_ide_vscode_install_extensions}"); do

        command="${Devbox_ide_vscode_run} ${Init_user_data_dir} --install-extension ${item}"
        [[ -n ${Codeinit_verbose} ]] && echo "Install VS code extension: ${command}"
        eval "${command}"
    done
fi

# parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_"

#TODO check extensions and install it
#TODO autocompletion init
#TODO check for statical checkers
#run composer
#run npm
# .vscode/
#   extensions.json:
#       {
#           "recommendations": [
#               "msjsdiag.debugger-for-chrome"
#          ]
#       }
#
# envs: https://github.com/microsoft/vscode/issues/68032
# terminal.integrated.env.{os}   linux or osx or windows . separator ; for windows

# "terminal.integrated.env.linux": {
#    "Devbox_WORKDIR": "/home",
#    "PATH": "${env:PATH}:/usr/local/bin"
#
#  }
