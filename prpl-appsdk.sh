#/bin/sh
#set -x

# Store the length of the input string

sdk="prpl-appsdk"
DUID=`id -u ${USER}`
DGUID=`id -g ${USER}`
DUSER=`whoami`
DGROUPS=`id -g -n ${USER}`

image="prplappsdk"
version="latest"
name=""

function print_usage() {
  echo "prpl Application SDK tools"
  echo "--------------------------"
  echo "  for user:group = $DUSER:$DGROUPS ($DUID:$DGUID)"
  echo "  docker image base is : $image:$version"
  echo "  Usage : $0 [start <DIRECTORY> |stop <DIRECTORY> | delete <DIRECTORY> | build | list ]"
  exit 1
}

function exit_status() {
  retVal=$?
  if [ $retVal -eq 1 ]; then
    echo "!!! error when running $1 !!!"
    exit 0
  else
    echo "### $1 Success ###"
    exit 1
  fi
}


if [ $# -eq 0 ]; then
  print_usage
fi


function get_directory() {
  str=$1
  length=${#1}
  if [ "${str: -1}" = "/" ]; then
    # Remove the last character"
    name="${str:0:length-1}"
  else
    # No change needed, keep the input string as it is
    name="$1"
  fi
}

function check_twoparams() {
  if [ $# -lt 2 ]; then
    print_usage
  fi
}

function build_sdk(){
  docker build --pull --rm -f "Dockerfile" -t $image:$version  "."
}

function is_build() {
  ver=`docker images | grep $image  | awk '{print $2}'`
  if [ $ver != $version ]; then
    build_sdk
  fi
}

function liste_sdk () {
  docker ps -f name=${image}_ --all
}

function is_run() { 
  RET=`docker ps -f name=$1 --all | wc -l`
  return $RET
}

function is_exited() { 
  RET=`docker ps -f name=$1 -f status=exited | wc -l`
  return $RET
}

function start() {
  is_build
  is_run $1
  if test  $? -eq 1
  then
		docker run -it --name $1  -e MY_USERNAME=$DUSER -e MY_GROUP=$DGROUPS -e MY_UID=$DUID -e MY_GID=$DGUID --mount source=$(pwd)/$2,target=/sdkworkdir/workspace,type=bind $image:$version 
  else
		is_exited $1
    if test  $? -eq 2
    then
      docker start $1
    fi
		#docker exec -it $1 su $DUSER
    docker exec -it $1 /bin/bash
  fi
}

function stop() {
  is_run $1
  if test  $? -gt 1 
  then
    is_exited $1
    if test  $? -eq 1
    then
      docker stop $1
    fi
  fi
}

function delete() {
  echo "delete with $@"
  stop "$@"
  is_exited $1
    if test  $? -eq 2
    then
       docker rm $1
    fi
}

case $1 in
  start)
    check_twoparams "$@"
    get_directory "$2"
    echo "-> Start SDK for $name"
    start "${image}_${name}" $2
    exit_status "start SDK"
  ;;
  stop)
    check_twoparams "$@"
    get_directory "$2"
    echo "-> Stop SDK for $name"
    stop "${image}_${name}" $2
    exit_status "stop SDK"
  ;;
  delete)
    check_twoparams "$@"
    get_directory "$2"
    echo "-> Delete SDK for $name" 
    delete "${image}_${name}" $2
    exit_status "delete SDK"
  ;;
  build)
    echo "-> Building SDK"
    build_sdk
    exit_status "building SDK"
  ;;
  list)
    echo "-> Listing SDK Docker images "
    liste_sdk
    exit_status "Listing SDK"
  ;;
	*)
    print_usage
    ;;
esac