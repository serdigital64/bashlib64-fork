#######################################
# BashLib64 / Module / Setup / Manage OS identity and access service
#######################################

#######################################
# Setup the bashlib64 module
#
# * Warning: bootstrap function
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: setup ok
#   >0: setup failed
#######################################
function bl64_iam_setup() {
  [[ -z "$BL64_VERSION" ]] && echo 'Error: bashlib64-module-core.bash must be sourced at the end' && return 21

  # shellcheck disable=SC2034
  _bl64_lib_module_is_imported 'BL64_CHECK_MODULE' &&
    _bl64_lib_module_is_imported 'BL64_DBG_MODULE' &&
    bl64_dbg_lib_show_function &&
    _bl64_lib_module_is_imported 'BL64_OS_MODULE' &&
    _bl64_lib_module_is_imported 'BL64_MSG_MODULE' &&
    _bl64_lib_module_is_imported 'BL64_RND_MODULE' &&
    _bl64_lib_module_is_imported 'BL64_FMT_MODULE' &&
    _bl64_iam_set_command &&
    _bl64_iam_set_alias &&
    _bl64_iam_set_options &&
    BL64_IAM_MODULE="$BL64_VAR_ON"
  bl64_check_alert_module_setup 'iam'
}

#######################################
# Identify and normalize commands
#
# * Commands are exported as variables with full path
# * The caller function is responsible for checking that the target command is present (installed)
# * Warning: bootstrap function
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function _bl64_iam_set_command() {
  bl64_dbg_lib_show_function

  case "$BL64_OS_DISTRO" in
  ${BL64_OS_UB}-* | ${BL64_OS_DEB}-* | ${BL64_OS_KL}-*)
    BL64_IAM_CMD_USERADD='/usr/sbin/useradd'
    BL64_IAM_CMD_USERMOD='/usr/sbin/usermod'
    BL64_IAM_CMD_GROUPADD='/usr/sbin/groupadd'
    BL64_IAM_CMD_GROUPMOD='/usr/sbin/groupmod'
    BL64_IAM_CMD_ID='/usr/bin/id'
    ;;
  ${BL64_OS_FD}-* | ${BL64_OS_AMZ}-* | ${BL64_OS_CNT}-* | ${BL64_OS_RHEL}-* | ${BL64_OS_ALM}-* | ${BL64_OS_OL}-* | ${BL64_OS_RCK}-*)
    BL64_IAM_CMD_USERADD='/usr/sbin/useradd'
    BL64_IAM_CMD_USERMOD='/usr/sbin/usermod'
    BL64_IAM_CMD_GROUPADD='/usr/sbin/groupadd'
    BL64_IAM_CMD_GROUPMOD='/usr/sbin/groupmod'
    BL64_IAM_CMD_ID='/usr/bin/id'
    ;;
  ${BL64_OS_SLES}-*)
    BL64_IAM_CMD_USERADD='/usr/sbin/useradd'
    BL64_IAM_CMD_USERMOD='/usr/sbin/usermod'
    BL64_IAM_CMD_GROUPADD='/usr/sbin/groupadd'
    BL64_IAM_CMD_GROUPMOD='/usr/sbin/groupmod'
    BL64_IAM_CMD_ID='/usr/bin/id'
    ;;
  ${BL64_OS_ALP}-*)
    BL64_IAM_CMD_ADDUSER='/usr/sbin/adduser'
    BL64_IAM_CMD_ADDGROUP='/usr/sbin/addgroup'
    BL64_IAM_CMD_ID='/usr/bin/id'
    ;;
  ${BL64_OS_MCOS}-*)
    BL64_IAM_CMD_SYSADMINCTL='/usr/sbin/sysadminctl'
    BL64_IAM_CMD_ID='/usr/bin/id'
    ;;
  *) bl64_check_alert_unsupported ;;
  esac
}

#######################################
# Create command aliases for common use cases
#
# * Aliases are presented as regular shell variables for easy inclusion in complex commands
# * Use the alias without quotes, otherwise the shell will interprete spaces as part of the command
# * Warning: bootstrap function
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function _bl64_iam_set_alias() {
  bl64_dbg_lib_show_function

  # shellcheck disable=SC2034
  case "$BL64_OS_DISTRO" in
  ${BL64_OS_UB}-* | ${BL64_OS_DEB}-* | ${BL64_OS_KL}-*)
    BL64_IAM_ALIAS_USERADD="$BL64_IAM_CMD_USERADD"
    ;;
  ${BL64_OS_FD}-* | ${BL64_OS_AMZ}-* | ${BL64_OS_CNT}-* | ${BL64_OS_RHEL}-* | ${BL64_OS_ALM}-* | ${BL64_OS_OL}-* | ${BL64_OS_RCK}-*)
    BL64_IAM_ALIAS_USERADD="$BL64_IAM_CMD_USERADD"
    ;;
  ${BL64_OS_SLES}-*)
    BL64_IAM_ALIAS_USERADD="$BL64_IAM_CMD_USERADD"
    ;;
  ${BL64_OS_ALP}-*)
    BL64_IAM_ALIAS_USERADD="$BL64_IAM_CMD_ADDUSER"
    ;;
  ${BL64_OS_MCOS}-*)
    BL64_IAM_ALIAS_USERADD="$BL64_IAM_CMD_SYSADMINCTL"
    ;;
  *) bl64_check_alert_unsupported ;;
  esac
}

#######################################
# Create command sets for common options
#
# * Warning: bootstrap function
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function _bl64_iam_set_options() {
  bl64_dbg_lib_show_function

  # shellcheck disable=SC2034
  case "$BL64_OS_DISTRO" in
  ${BL64_OS_UB}-* | ${BL64_OS_DEB}-* | ${BL64_OS_KL}-*)
    BL64_IAM_SET_USERADD_CREATE_HOME='--create-home'
    BL64_IAM_SET_USERADD_GECO='--comment'
    BL64_IAM_SET_USERADD_GROUP='--gid'
    BL64_IAM_SET_USERADD_HOME_PATH='--home-dir'
    BL64_IAM_SET_USERADD_SHELL='--shell'
    BL64_IAM_SET_USERADD_UID='--uid'

    BL64_IAM_SYSTEM_USER='root'
    BL64_IAM_SYSTEM_GROUP='root'
    ;;
  ${BL64_OS_FD}-* | ${BL64_OS_AMZ}-* | ${BL64_OS_CNT}-* | ${BL64_OS_RHEL}-* | ${BL64_OS_ALM}-* | ${BL64_OS_OL}-* | ${BL64_OS_RCK}-*)
    BL64_IAM_SET_USERADD_CREATE_HOME='--create-home'
    BL64_IAM_SET_USERADD_GECO='--comment'
    BL64_IAM_SET_USERADD_GROUP='--gid'
    BL64_IAM_SET_USERADD_HOME_PATH='--home-dir'
    BL64_IAM_SET_USERADD_SHELL='--shell'
    BL64_IAM_SET_USERADD_UID='--uid'

    BL64_IAM_SYSTEM_USER='root'
    BL64_IAM_SYSTEM_GROUP='root'
    ;;
  ${BL64_OS_SLES}-*)
    BL64_IAM_SET_USERADD_CREATE_HOME='--create-home'
    BL64_IAM_SET_USERADD_GECO='--comment'
    BL64_IAM_SET_USERADD_GROUP='--gid'
    BL64_IAM_SET_USERADD_HOME_PATH='--home-dir'
    BL64_IAM_SET_USERADD_SHELL='--shell'
    BL64_IAM_SET_USERADD_UID='--uid'

    BL64_IAM_SYSTEM_USER='root'
    BL64_IAM_SYSTEM_GROUP='root'
    ;;
  ${BL64_OS_ALP}-*)
    BL64_IAM_SET_USERADD_CREATE_HOME=' '
    BL64_IAM_SET_USERADD_GECO='-g'
    BL64_IAM_SET_USERADD_GROUP='-G'
    BL64_IAM_SET_USERADD_HOME_PATH='-h'
    BL64_IAM_SET_USERADD_SHELL='-s'
    BL64_IAM_SET_USERADD_UID='-u'

    BL64_IAM_SYSTEM_USER='root'
    BL64_IAM_SYSTEM_GROUP='root'
    ;;
  ${BL64_OS_MCOS}-*)
    BL64_IAM_SET_USERADD_CREATE_HOME=' '
    BL64_IAM_SET_USERADD_GECO='-fullName'
    BL64_IAM_SET_USERADD_GROUP='-gid'
    BL64_IAM_SET_USERADD_HOME_PATH='-home'
    BL64_IAM_SET_USERADD_SHELL='-shell'
    BL64_IAM_SET_USERADD_UID='-UID'

    BL64_IAM_SYSTEM_USER='root'
    BL64_IAM_SYSTEM_GROUP='wheel'
    ;;
  *) bl64_check_alert_unsupported ;;
  esac
}
