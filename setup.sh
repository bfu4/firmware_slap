#!/bin/bash

RED="\033[1;31m"
PURPLE="\033[1;35m"
RESET="\033[0m"
NEWLINE="\n"

function err() {
   printf "${RED}[error]${RESET} $@${NEWLINE}"
}

function info() {
   printf "${PURPLE}[!]${RESET} $@${NEWLINE}"
}

function verify_command() {
   local command="$1"
   if [[ -z $(which "${command}") ]]; then
      err "${command} not found"
      exit 1
   fi
}

PIP_PACKAGES="tqdm python-magic IPython tqdm sklearn matplotlib r2pipe matplotlib angr psutil termcolor celery flower"
PACKAGES="rabbitmq-server ca-certificates curl gnupg lsb-release"
INSTALLER=""
INSTALLER_SUDO="sudo"

function get_package_manager() {
   if [[ ! -z $(which apt) ]]; then
     INSTALLER="apt install"
   elif [[ ! -z $(which apk) ]]; then
     INSTALLER="apk add"
   elif [[ ! -z $(which pacman) ]]; then
     INSTALLER="pacman -S"
   elif [[ ! -z $(which yum) ]]; then
     INSTALLER="yum install"
   elif [[ ! -z $(which dnf) ]]; then
     INSTALLER="dnf install"
   elif [[ ! -z $(which zypper) ]]; then
     INSTALLER="zypper install"
   else 
     err 'package manager not found'
     exit 1
   fi
}

if [[ "$(uname)" -eq "Darwin" ]]; then
   err 'tool not supported on mac os!'
   exit 1
fi

# Find pip
verify_command "pip"
PIP=$(which pip)
info "found pip!: ${PIP}"

# Find package manager
get_package_manager
info "found package manager!: ${INSTALLER}" 

info "installing dist packages"
bash -c "${INSTALLER_SUDO} ${INSTALLER} ${PACKAGES}"

info "installing python packages"
bash -c "${PIP} install ${PIP_PACKAGES}"

# ./fix_strtol.sh
