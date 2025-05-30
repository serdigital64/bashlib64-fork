#######################################
# BashLib64 / Module / Setup / Manipulate CSV like text files
#######################################

#######################################
# Setup the bashlib64 module
#
# Arguments:
#   $@: (optional) search full paths for tools
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: setup ok
#   >0: setup failed
#######################################
function bl64_xsv_setup() {
  [[ -z "$BL64_VERSION" ]] && echo 'Error: bashlib64-module-core.bash must be sourced at the end' && return 21
  local search_paths=("${@:-}")

  # shellcheck disable=SC2034
  _bl64_lib_module_is_imported 'BL64_DBG_MODULE' &&
    bl64_dbg_lib_show_function &&
    _bl64_lib_module_is_imported 'BL64_CHECK_MODULE' &&
    _bl64_lib_module_is_imported 'BL64_TXT_MODULE' &&
    _bl64_lib_module_is_imported 'BL64_BSH_MODULE' &&
    _bl64_xsv_set_command "${search_paths[@]}" &&
    BL64_XSV_MODULE="$BL64_VAR_ON"
  bl64_check_alert_module_setup 'xsv'
}

#######################################
# Identify and normalize commands
#
# * If no values are provided, try to detect commands looking for common paths
# * Commands are exported as variables with full path
# * All commands are optional, no error if not found
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function _bl64_xsv_set_command() {
  bl64_dbg_lib_show_function "$@"
  BL64_XSV_CMD_JQ="$(bl64_bsh_command_locate 'jq' "$@")"
  BL64_XSV_CMD_YQ="$(bl64_bsh_command_locate 'yq' "$@")"
  return 0
}
