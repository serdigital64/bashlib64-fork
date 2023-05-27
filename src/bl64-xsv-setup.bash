#######################################
# BashLib64 / Module / Setup / Manipulate CSV like text files
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
function bl64_xsv_setup() {
  bl64_dbg_lib_show_function

  BL64_XSV_MODULE="$BL64_VAR_ON"

  bl64_check_alert_module_setup 'xsv'
}