environment_create()
{
  # TODO: test environment
  #status "Create new devbox environment"
  # TODO: get envi
  local Create_name
  local Create_source
  if [[ -n ${Environment_verbose} ]]
  then
    echo "Enter the name of new environment. Environment name should include letters and digits."
    echo "environment configuration to be stored in etc/env/[name].yaml"
  fi
  read -p -r "Environment name:" Create_name
  echo "New environment to be created is: ${Create_name}"
  #TODO validate name
  #TODO check if environment with entered name already exist

  if [[ -n ${Environment_verbose} ]]
  then
    #TODO color
    echo "Environment source could be \"directory\" or git paths."
    echo "if you enter \"directory\" as source, appropriate directory should already to be exist: etc/helm/${Create_name}/"
    echo "if you will enter git path to, script would download it using git"
  fi
  read -p -r "Environment source:" Create_source
  if [ "${Create_source}" == "directory" ]; then
    if [ ! -d "etc/helm/${Create_source}" ]; then
      echo "Directory does not exist: etc/helm/${Create_source}"
      echo "Create directory and configuration files before devbox environment create"
      exit 1
    fi
    #TODO  validate configuration files
    echo "Source directory validated: ${Create_source}"
  else
    #TODO validate source path
    echo "git pull ${Create_source}"
    # git pull to etc/helm/${Create_name}/
  fi
}

environment_create