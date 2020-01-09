#!/usr/bin/env bash
#
# Development Environment minikube status script for Magento Commerce 
#
# @Arguments: [] [-f|--force|-v|--verbose|--version|--debug]
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @source https://github.com/serge-kaimin/magento2-kubernetes-devbox
# shellcheck disable=SC2154
# shellcheck disable=SC1090

#TODO check if --force then --purge=true
echo "delete minikube environment. Use --force flag to purge all data"
minikube status

# end bin/environment/kubenrnetes/minikube-delete.bash

