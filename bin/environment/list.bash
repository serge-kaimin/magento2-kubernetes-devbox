#
## Command create
#
environment_list()
{
  # shellcheck disable=SC2154
  if [[ -n ${Environment_verbose} ]]
  then
    status "List devbox environment"
  fi
  echo "magento2"
  echo "pwa-studio"
}

environment_list
