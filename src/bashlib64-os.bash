#######################################
# BashLib64 / Identify OS attributes
#
# Author: serdigital64 (https://github.com/serdigital64)
# License: GPL-3.0-or-later (https://www.gnu.org/licenses/gpl-3.0.txt)
# Repository: https://github.com/serdigital64/bashlib64
# Version: 1.0.3
#######################################

#
# Internal Functions
#

#
# Exported Functions
#

#######################################
# Identify and normalize Linux OS distribution name and version
#
# Globals:
#   BL64_OS_DISTRO
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: ok: always ok, even when unable to identify the platform
#######################################
function bl64_os_get_distro() {

  BL64_OS_DISTRO='UNKNOWN'

  if [[ -r '/etc/os-release' ]]; then

    # shellcheck disable=SC1091
    source '/etc/os-release'

    if [[ -n "$ID" && -n "$VERSION_ID" ]]; then
      BL64_OS_DISTRO="${ID^^}-${VERSION_ID}"
    fi

  fi

  return 0
}

#######################################
# Identify and normalize common *nix OS commands
# Commands are exported as variables with full path
#
# Globals:
#   BL64_OS_DISTRO
#   BL64_OS_CMD_AWK
#   BL64_OS_CMD_CAT
#   BL64_OS_CMD_CHMOD
#   BL64_OS_CMD_CHOWN
#   BL64_OS_CMD_CP
#   BL64_OS_CMD_CAT
#   BL64_OS_CMD_DATE
#   BL64_OS_CMD_HOSTNAME
#   BL64_OS_CMD_ID
#   BL64_OS_CMD_LS
#   BL64_OS_CMD_MKDIR
#   BL64_OS_CMD_RM
#   BL64_OS_CMD_SUDO
#   BL64_OS_CMD_USERADD
#   BL64_OS_CMD_APT
#   BL64_OS_CMD_DNF
#   BL64_OS_CMD_YUM
# Arguments:
#   STDOUT: None
#   STDERR: None
# Outputs:
#   None
# Returns:
#   0: always ok, even when the OS is not supported
#######################################
function bl64_os_set_command() {
  if [[ "$BL64_OS_DISTRO" =~ (UBUNTU-.*|FEDORA-.*|CENTOS-.*|OL-.*|DEBIAN-.*) ]]; then
    BL64_OS_CMD_AWK='/usr/bin/awk'
    BL64_OS_CMD_SUDO='/usr/bin/sudo'
    BL64_OS_CMD_USERADD='/usr/sbin/useradd'
  fi
  if [[ "$BL64_OS_DISTRO" =~ (UBUNTU-.*|DEBIAN-.*) ]]; then
    BL64_OS_CMD_DATE="/bin/date"
    BL64_OS_CMD_HOSTNAME='/bin/hostname'
    BL64_OS_CMD_MKDIR='/bin/mkdir'
    BL64_OS_CMD_RM='/bin/rm'
    BL64_OS_CMD_CHMOD='/bin/chmod'
    BL64_OS_CMD_CHOWN='/bin/chown'
    BL64_OS_CMD_CP='/bin/cp'
    BL64_OS_CMD_LS='/bin/ls'
    BL64_OS_CMD_ID='/bin/id'
    BL64_OS_CMD_CAT='/bin/cat'
    BL64_OS_CMD_APT='/usr/bin/apt-get'
  fi
  if [[ "$BL64_OS_DISTRO" =~ (FEDORA-.*|CENTOS-.*|OL-.*) ]]; then
    BL64_OS_CMD_DATE="/usr/bin/date"
    BL64_OS_CMD_HOSTNAME='/usr/bin/hostname'
    BL64_OS_CMD_MKDIR='/usr/bin/mkdir'
    BL64_OS_CMD_RM='/usr/bin/rm'
    BL64_OS_CMD_CHMOD='/usr/bin/chmod'
    BL64_OS_CMD_CHOWN='/usr/bin/chown'
    BL64_OS_CMD_CP='/usr/bin/cp'
    BL64_OS_CMD_LS='/usr/bin/ls'
    BL64_OS_CMD_ID='/usr/bin/id'
    BL64_OS_CMD_CAT='/usr/bin/cat'
    BL64_OS_CMD_DNF='/usr/bin/dnf'
    BL64_OS_CMD_YUM='/usr/bin/yum'
  fi

  return 0
}

#######################################
# Create command aliases for common use cases
# Aliases are presented as regular shell variables for easy inclusion in SUDO
# Use the alias without quotes, otherwise the shell will interprete spaces as part of the command
#
# Globals:
#  BL64_OS_ALIAS_APT_CACHE
#  BL64_OS_ALIAS_APT_INSTALL
#  BL64_OS_ALIAS_CHOWN_DIR
#  BL64_OS_ALIAS_CP_FILE
#  BL64_OS_ALIAS_DNF_CACHE
#  BL64_OS_ALIAS_DNF_INSTALL
#  BL64_OS_ALIAS_ID_USER
#  BL64_OS_ALIAS_LS_FILES
#  BL64_OS_ALIAS_SUDO_ENV
# Arguments:
#   STDOUT: None
#   STDERR: None
# Outputs:
#   None
# Returns:
#   0: always ok
#######################################
function bl64_os_set_alias() {

  BL64_OS_ALIAS_LS_FILES="$BL64_OS_CMD_LS --color=never"
  BL64_OS_ALIAS_ID_USER="$BL64_OS_CMD_ID -u -n"
  BL64_OS_ALIAS_CP_FILE="$BL64_OS_CMD_CP --verbose --force"
  BL64_OS_ALIAS_CHOWN_DIR="$BL64_OS_CMD_CHOWN --verbose --recursive"
  BL64_OS_ALIAS_SUDO_ENV="$BL64_OS_CMD_SUDO --preserve-env --set-home"

  if [[ "$BL64_OS_DISTRO" =~ (UBUNTU-.*|DEBIAN-.*) ]]; then
    BL64_OS_ALIAS_APT_CACHE="$BL64_OS_CMD_APT update"
    BL64_OS_ALIAS_APT_INSTALL="$BL64_OS_CMD_APT --assume-yes install"
  fi

  if [[ "$BL64_OS_DISTRO" =~ (FEDORA-.*|CENTOS-.*|OL-.*) ]]; then
    BL64_OS_ALIAS_DNF_CACHE="$BL64_OS_CMD_DNF --color=never makecache"
    BL64_OS_ALIAS_DNF_INSTALL="$BL64_OS_CMD_DNF --color=never --nodocs --assumeyes install"
  fi

}