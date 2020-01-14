#!/usr/bin/env bash
#
# devbox tool to manage Magento Commerce development environment
#
# @Arguments: [environment|project|ssh|magento|composer|yarn|version|get|set|show] [--force|--verbose|--version|--help]
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

#Devbox_version=$(grep @version -m 1 "${devbox_dir}"/devbox.bash | tr -s ' ' | cut -d ' ' -f 3)

## Parse shell comands, sub-comands, arguments, anf flags
# TODO: move it to external script and change values of assigned options from array Devbox_name="name of devbox"
# shellcheck disable=SC1090
source "${devbox_dir}/scripts/bash-parameters-parsing.sh"
# shellcheck disable=SC1090
source "${devbox_dir}/bin/include/common.bash"
Arg_parser_prefix="Helm_"
# shellcheck disable=SC2046
eval $(parse_params "${@}" )

eval "$(parse_yaml "${devbox_dir}/etc/Devbox.yaml" "export Devbox_")"
[[ -n ${Helm_verbose} ]] && (parse_yaml "${devbox_dir}/etc/Devbox.yaml" "Devbox_")

#TODO identify default project

command="${Helm_ARGV[0]}"

project=${Devbox_env_default}
project_directory="$(get_value_by_name "Devbox_env_project_${project}_helm_path")"
project_path="${devbox_dir}/etc/project/${project}/helm/${project_directory}/"

echo "Source code to be installed: ${project_path}"

#TODO lint for specific commands
cd "${devbox_dir}/etc/helm"
helm lint "${project_path}" #--strict 
if [ $? -eq 0 ]
then
    echo "Lint OK"
else
    echo "Lint not passed"
    exit 1
fi

case ${command} in  
    install)
        # TODO check before delete project
        [[ -n ${Helm_force} ]] && helm delete "${project}"
        #helm delete "${project}"
        helm install "${project}" "${project_path}" #--debug #--dry-run
        echo "$(kubectl get pods | grep -ohE '${project}-[a-z0-9\-]+')"

        exit 0
        ;;
    start)
        echo "$(kubectl get pods | grep -ohE '${project}-[a-z0-9\-]+')"
        ;;
    dry-run)
        debug_helm=""
        [[ -n ${Helm_debug} ]] && debug_helm="--debug"
        helm install "${project}" "${project_path}" --dry-run ${debug_helm}
        exit 0
        ;;
    lint)
        helm lint "${project_path}" --strict 
        #TODO check exit code
        exit 0
        ;;
    delete)
        helm delete "${project}"
        exit 0
        ;;
    helm)
        #TODO help
        echo "commands available: install, start, delete, dry-run, lint"
        ;;
    *)
        echo "Comand not recognized:${command}"
        ;;
esac
