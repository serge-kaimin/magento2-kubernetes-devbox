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

# shellcheck disable=SC2034
Arg_parser_prefix="IDE_" 
eval $(parse_params "${@}")
[[ -n ${IDE_verbose} ]] && parse_params "${@}"

#Evaluate default configuration if available
eval "$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"

function bash_run () { 
    command_args="$(IFS=" "; echo "${IDE_ARGV[@]}" | cut -d' ' -f2-)"
    command_options="$(IFS=" "; echo "${IDE_ARGO[@]}")"
    command_options="$(IFS=" "; echo "${IDE_ARGO[@]}") $(IFS=" "; echo "${IDE_ARGN[@]}")"
    command_path="${devbox_dir}/bin/ide/${IDE_name}.bash"
    comannd_run="${command_path} ${command_args} ${command_options}"

    case ${IDE_name} in
        code)
            command_path="${devbox_dir}/bin/ide/vscode.bash"
            comannd_run="${command_path} ${command_args} ${command_options}"
            eval "${comannd_run}"
            exit 0 
            ;;
        phpstorm)
            eval "${comannd_run}"
            exit 0 
            ;;
        default)
            [[ -n ${Bash_verbose} ]] && echo "Default IDE:${Devbox_ide_default}"
            if [[ -n ${Devbox_ide_default} ]]; then
                IDE_name=${Devbox_ide_default} 
                command_path="${devbox_dir}/bin/ide/${IDE_name}.bash"
                comannd_run="${command_path} ${command_args} ${command_options}"
                eval "${comannd_run}"
                exit 0
            else
                echo "No default IDE configured for devbox"
            fi
            ;;
        ide) return 0;;
        *)
            echo "Unkknown option supplied: ${IDE_name}"
            exit 1
            ;;
esac

}

# check if "devbox <name>" was supplied in arguments
IDE_name="${IDE_ARGV[0]}"
bash_run

# devbox ide 
if [[ -n ${Devbox_ide_default} ]]; then
    echo "default IDE:${Devbox_ide_default}"
    IDE_name="default"
    bash_run
else
    echo "No default ide configured for devbox available"
    exit 1
fi
