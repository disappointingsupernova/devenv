#!/bin/bash

set -euo pipefail

source "$_DEVENV_ROOT/libs/config.sh"

PROFILE_PATHS="$(__devenv_config_get "profiles")"

source "$_DEVENV_ROOT/libs/plugins/bin.sh"
source "$_DEVENV_ROOT/libs/plugins/email.sh"
source "$_DEVENV_ROOT/libs/plugins/envs.sh"
source "$_DEVENV_ROOT/libs/plugins/gpg.sh"
source "$_DEVENV_ROOT/libs/plugins/ssh.sh"
source "$_DEVENV_ROOT/libs/plugins/aws.sh"
source "$_DEVENV_ROOT/libs/plugins/shell-history.sh"

__devenv_profile_get_active() {
  DEVENV_ACTIVE_PROFILE=${DEVENV_ACTIVE_PROFILE:-}
  [[ "$DEVENV_ACTIVE_PROFILE" ]] && echo "$DEVENV_ACTIVE_PROFILE"
  echo ""
}

__devenv_profile_exists() {
  local profile_name
  profile_name=$1
  if [ ! -d "$PROFILE_PATHS/$profile_name" ]; then
    return 1
  else
    return 0
  fi
}

__devenv_profile_create() {
  local profile_name
  profile_name=$1
  local profile_folder
  profile_folder=$2
  __devenv_profile_exists "$profile_name" || mkdir "$profile_folder"
  [ -d "$profile_folder/.config" ] || mkdir "$profile_folder/.config"
  return 0
}

__devenv_profile_generate_loader() {
  local profile
  profile=$1
  local profile_folder
  profile_folder="$PROFILE_PATHS/$profile"

  echo "#!/bin/bash"
  echo "#"
  echo "# This file has been automatically generated with devenv"
  echo "# Please remember that running 'devenv rehash' will overwrite this file :)"
  echo ""
  echo "export DEVENV_ACTIVE_PROFILE='$profile'"
  echo "export DEVENV_ACTIVE_PROFILE_PATH='$profile_folder'"

  echo "# plugin BEGIN"
  echo "# plugin: aws"
  __devenv_plugin__aws__generate_loader "$profile_folder" "$profile"
  echo "# plugin: bin"
  __devenv_plugin__bin__generate_loader "$profile_folder" "$profile"
  echo "# plugin: email"
  __devenv_plugin__email__generate_loader "$profile_folder" "$profile"
  echo "# plugin: envs"
  __devenv_plugin__envs__generate_loader "$profile_folder" "$profile"
  echo "# plugin: gpg"
  __devenv_plugin__gpg__generate_loader "$profile_folder" "$profile"
  echo "# plugin: ssh"
  __devenv_plugin__ssh__generate_loader "$profile_folder" "$profile"
  echo "# plugin: shellhistory"
  __devenv_plugin__shellhistory__generate_loader "$profile_folder" "$profile"
  echo "# plugin END"
}
