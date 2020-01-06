#!/usr/bin/env bash
#
# Development Environment minikube status script for Magento Commerce 
#
# @Arguments: [] [-f|--force|-v|--verbose|--version|--debug]
# @author Sergey Kaimin (serge.kaimin@gmail.com)
# @source https://github.com/serge-kaimin/magento2-kubernetes-devbox
# shellcheck disable=SC2154
# shellcheck disable=SC1090

echo "minikube status"
minikube status

# end bin/environment/status/minikube.bash