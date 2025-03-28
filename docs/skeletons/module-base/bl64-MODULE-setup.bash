#######################################
# BashLib64 / Module / Setup / X_MODULE_OVERVIEW_X
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
function bl64_X_MODULE_ID_X_setup() {
  [[ -z "$BL64_VERSION" ]] && echo 'Error: bashlib64-module-core.bash must be sourced at the end' && return 21

  # shellcheck disable=SC2034
  _bl64_lib_module_is_imported 'BL64_CHECK_MODULE' &&
    _bl64_lib_module_is_imported 'BL64_DBG_MODULE' &&
    bl64_dbg_lib_show_function &&
    # X_SETUP_DEPENDENCIES_PLACEHOLDER_X
    # _bl64_X_MODULE_ID_X_set_command &&
    # _bl64_X_MODULE_ID_X_set_options &&
    BL64_X_MODULE_ID_X_MODULE="$BL64_VAR_ON"
  bl64_check_alert_module_setup 'X_MODULE_ID_X'
}

# X_MODULE_SETUP_PLACEHOLDER_X
