

environment_clean()
{
  status "Clean up the environmen before initialization"
  force_project_cleaning=0
  #force_project_cleaning=0
  #force_codebase_cleaning=0
  force_phpstorm_config_cleaning=0

  if [[ $(isMinikubeRunning) -eq 1 ]]; then
    minikube stop 2> >(logError) | {
      while IFS= read -r line; do
        filterDevboxOutput "${line}"
        lastline="${line}"
      done
      filterDevboxOutput "${lastline}"
    }
  fi

  if [[ $(isMinikubeStopped) -eq 1 ]]; then
    minikube delete 2> >(logError) | {
      while IFS= read -r line; do
        filterDevboxOutput "${line}"
        lastline="${line}"
      done
      filterDevboxOutput "${lastline}"
    }
  fi

  cd "${devbox_dir}/log" && mv email/.gitignore email_gitignore.back && rm -rf email && mkdir email && mv email_gitignore.back email/.gitignore
  
  if [[ ${force_project_cleaning} -eq 1 ]] && [[ ${force_phpstorm_config_cleaning} -eq 1 ]]; then
    status "Resetting PhpStorm configuration since '-p' option was used"
    rm -rf "${devbox_dir}/.idea"
  fi

  #devbox.bash ide <name> --clean --force
  
}

environment_clean