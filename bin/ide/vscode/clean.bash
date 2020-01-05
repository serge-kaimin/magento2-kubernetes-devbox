#!/usr/bin/env bash
#
# Development Environment IDE for Magento Commerce 
#
# @Arguments: [<ide-name>] [--init][--force|--verbose|--version|--debug]
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @source https://github.com/serge-kaimin/magento2-kubernetes-devbox
# shellcheck disable=SC2154
# shellcheck disable=SC1090

#
## Change workdir if $Devbox_WORKDIR and include common
# shellcheck disable=SC2154

[ -z "${Devbox_WORKDIR}" ] && devbox_dir=$PWD || devbox_dir=${Devbox_WORKDIR}
. "${devbox_dir}/bin/include/common.bash"

echo "Clean Microsoft Visual Code environment"
echo "Disk usage:"
#disk before clean: du -d0 ${devbox_dir}/etc/ide/vscode/
eval "du ${devbox_dir}/etc/ide/vscode/"

command="rm -r ${devbox_dir}/etc/ide/vscode/default.userdata"
echo "${command}"

#eval ${command} #- uncomment when tested

echo "Run command manually to clean environment"

#TODO: run after delete. 
#disk was: du -d0 ${devbox_dir}/etc/ide/vscode/
#calculate difference
#echo "Disk usage:"
#eval "du ${devbox_dir}/etc/ide/vscode/"
