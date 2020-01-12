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

#Devbox_version=$(grep @version -m 1 "${devbox_dir}"/devbox.bash | tr -s ' ' | cut -d ' ' -f 3)

## Parse shell comands, sub-comands, arguments, anf flags
# TODO: move it to external script and change values of assigned options from array Devbox_name="name of devbox"
source "${devbox_dir}/scripts/bash-parameters-parsing.sh"
Arg_parser_prefix="Helm_"
# shellcheck disable=SC2046
eval $(parse_params "${@}" )

#TODO identify default instance

command="${Helm_ARGV[0]}"

case ${command} in  
    install)
        cd "${devbox_dir}/etc/helm"
        ## TODO check --force
        helm install magento2 magento2/ #--debug #--dry-run
        exit 0
        ;;
    dry-run)
        #cd "${devbox_dir}/etc/helm"
        helm install magento2 "${devbox_dir}/etc/helm/magento2/" --dry-run #--debug 
        exit 0
        ;;
    lint)
        helm lint "${devbox_dir}/etc/helm/magento2/" --strict 
        #TODO check exit code
        exit 0
        ;;
    delete)
        helm delete magento2
        exit 0
        ;;
esac



cd "${devbox_dir}/etc/helm"
helm lint "${devbox_dir}/etc/helm/magento2/" #--strict 
if [ $? -eq 0 ]
then
    echo "Lint passed"
    helm delete magento2
    helm install magento2 magento2/ #--debug
fi

#$(cd "${devbox_dir}/etc/helm" ; helm delete magento2 )

#$(cd "${devbox_dir}/etc/helm" ; helm install magento2 magento2/ )


# dive magento2-nginx:1.17
# echo "$(kubectl get pods | grep -ohE 'magento2-[a-z0-9\-]+')"

echo "$(kubectl get pods | grep -ohE 'magento2-[a-z0-9\-]+')"

