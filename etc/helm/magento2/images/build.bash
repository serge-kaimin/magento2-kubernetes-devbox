## Change workdir if $Devbox_WORKDIR
# shellcheck disable=SC2154
[ -z "${Devbox_WORKDIR}" ] && devbox_dir=$PWD || devbox_dir=${Devbox_WORKDIR}

# build nginx
#D=$PWD
# configure your shell to build images it DOCKER_HOST

build_docker () 
{
    docker_name="${1}"
    docker_ver="${2}"

    echo "Build image: ${docker_name}:${docker_ver}"
    dockername="${docker_name}:${docker_ver}"
    dockerfile="${docker_name}/${docker_ver}/Dockerfile"
    dockerpath="${docker_name}/${docker_ver}/"

    echo "docker build --tag ${dockername} --file ${dockerfile} ${dockerpath}"
    docker build --tag ${dockername} --file ${dockerfile} ${dockerpath}

}

#TODO check for doker environment kind or minikube
eval "$(minikube docker-env)"

docker_name="magento2-nginx"
docker_version="1.16"
nginx_ver="1.16"

#

#build_docker ${docker_name} ${docker_version}
#TODO check which version is required by current config
build_docker magento2-nginx 1.15

#TODO check if versions updateed 
build_docker magento2-php-fpm 7.2

echo "Build nginx image: ${docker_name}:${nginx_ver}"
dockername="${docker_name}:${nginx_ver}"
dockerfile="${docker_name}/${nginx_ver}/Dockerfile"
dockerpath="${docker_name}/${nginx_ver}/"

#docker build -t ${dockername} -f ${dockerfile} ${dockerpath}
#docker build -t magento2-nginx:1.17 -f magento2-nginx/1.17/Dockerfile magento2-nginx/1.17/
#command="eval $(minikube docker-env) && docker build -t magento2-nginx:${nginx_ver} -f magento2-nginx/${nginx_ver}/Dockerfile magento2-nginx/${nginx_ver}/"
#echo ${command}
#$(command)

fpm_ver=7.2
# build php-fpm
#echo "Build magento2-php-fpm image: magento2-php-fpm:${fpm_ver}"
#docker build -t magento2-php-fpm:7.3 -f php-fpm/7.3/Dockerfile php-fpm/7.3/
#command="eval $(minikube docker-env) && docker build -t magento2-php-fpm:${fpm_ver} -f php-fpm/${fpm_ver}/Dockerfile php-fpm/${fpm_ver}/"
#eval $(command)

#helm install magento2 magento2/
