#######################################
# BashLib64 / Module / Setup / Manipulate text files content
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
function bl64_txt_setup() {
  [[ -z "$BL64_VERSION" ]] && echo 'Error: bashlib64-module-core.bash must be sourced at the end' && return 21

  # shellcheck disable=SC2034
  _bl64_lib_module_is_imported 'BL64_CHECK_MODULE' &&
    _bl64_lib_module_is_imported 'BL64_DBG_MODULE' &&
    bl64_dbg_lib_show_function &&
    _bl64_lib_module_is_imported 'BL64_OS_MODULE' &&
    _bl64_txt_set_command &&
    _bl64_txt_set_options &&
    BL64_TXT_MODULE="$BL64_VAR_ON"
  bl64_check_alert_module_setup 'txt'
}

#######################################
# Identify and normalize common *nix OS commands
#
# * Commands are exported as variables with full path
# * For AWK the function will determine the best option to match posix awk
# * Warning: bootstrap function
# * AWS: provide legacy AWS, posix AWS and modern AWS when available
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok, even when the OS is not supported
#######################################
# Warning: bootstrap function
function _bl64_txt_set_command() {
  bl64_dbg_lib_show_function

  # shellcheck disable=SC2034
  case "$BL64_OS_DISTRO" in
  ${BL64_OS_UB}-* | ${BL64_OS_DEB}-* | ${BL64_OS_KL}-*)
    BL64_TXT_CMD_AWK='/usr/bin/awk'
    BL64_TXT_CMD_BASE64='/usr/bin/base64'
    BL64_TXT_CMD_CUT='/usr/bin/cut'
    BL64_TXT_CMD_ENVSUBST='/usr/bin/envsubst'
    BL64_TXT_CMD_GAWK='/usr/bin/gawk'
    BL64_TXT_CMD_GREP='/bin/grep'
    BL64_TXT_CMD_FMT='/bin/fmt'
    BL64_TXT_CMD_SED='/bin/sed'
    BL64_TXT_CMD_SORT='/usr/bin/sort'
    BL64_TXT_CMD_TAIL='/usr/bin/tail'
    BL64_TXT_CMD_TR='/usr/bin/tr'
    BL64_TXT_CMD_UNIQ='/usr/bin/uniq'

    if [[ -x '/usr/bin/gawk' ]]; then
      BL64_TXT_CMD_AWK_POSIX='/usr/bin/gawk'
    elif [[ -x '/usr/bin/mawk' ]]; then
      BL64_TXT_CMD_AWK_POSIX='/usr/bin/mawk'
    fi
    ;;
  ${BL64_OS_FD}-* | ${BL64_OS_AMZ}-* | ${BL64_OS_CNT}-* | ${BL64_OS_RHEL}-* | ${BL64_OS_ALM}-* | ${BL64_OS_OL}-* | ${BL64_OS_RCK}-*)
    BL64_TXT_CMD_AWK='/usr/bin/awk'
    BL64_TXT_CMD_BASE64='/usr/bin/base64'
    BL64_TXT_CMD_CUT='/usr/bin/cut'
    BL64_TXT_CMD_ENVSUBST='/usr/bin/envsubst'
    BL64_TXT_CMD_GAWK='/usr/bin/gawk'
    BL64_TXT_CMD_GREP='/usr/bin/grep'
    BL64_TXT_CMD_FMT='/usr/bin/fmt'
    BL64_TXT_CMD_SED='/usr/bin/sed'
    BL64_TXT_CMD_SORT='/usr/bin/sort'
    BL64_TXT_CMD_TAIL='/usr/bin/tail'
    BL64_TXT_CMD_TR='/usr/bin/tr'
    BL64_TXT_CMD_UNIQ='/usr/bin/uniq'

    BL64_TXT_CMD_AWK_POSIX='/usr/bin/gawk'
    ;;
  ${BL64_OS_SLES}-*)
    BL64_TXT_CMD_AWK='/usr/bin/gawk'
    BL64_TXT_CMD_BASE64='/usr/bin/base64'
    BL64_TXT_CMD_CUT='/usr/bin/cut'
    BL64_TXT_CMD_ENVSUBST='/usr/bin/envsubst'
    BL64_TXT_CMD_GAWK='/usr/bin/gawk'
    BL64_TXT_CMD_GREP='/usr/bin/grep'
    BL64_TXT_CMD_FMT='/usr/bin/fmt'
    BL64_TXT_CMD_SED='/usr/bin/sed'
    BL64_TXT_CMD_SORT='/usr/bin/sort'
    BL64_TXT_CMD_TAIL='/usr/bin/tail'
    BL64_TXT_CMD_TR='/usr/bin/tr'
    BL64_TXT_CMD_UNIQ='/usr/bin/uniq'

    BL64_TXT_CMD_AWK_POSIX='/usr/bin/gawk'
    ;;
  ${BL64_OS_ALP}-*)
    BL64_TXT_CMD_AWK='/usr/bin/awk'
    BL64_TXT_CMD_BASE64='/bin/base64'
    BL64_TXT_CMD_CUT='/usr/bin/cut'
    BL64_TXT_CMD_ENVSUBST='/usr/bin/envsubst'
    BL64_TXT_CMD_GAWK='/usr/bin/gawk'
    BL64_TXT_CMD_GREP='/bin/grep'
    BL64_TXT_CMD_FMT='/bin/fmt'
    BL64_TXT_CMD_SED='/bin/sed'
    BL64_TXT_CMD_SORT='/usr/bin/sort'
    BL64_TXT_CMD_TAIL='/usr/bin/tail'
    BL64_TXT_CMD_TR='/usr/bin/tr'
    BL64_TXT_CMD_UNIQ='/usr/bin/uniq'

    if [[ -x '/usr/bin/gawk' ]]; then
      BL64_TXT_CMD_AWK_POSIX='/usr/bin/gawk'
    else
      bl64_dbg_lib_show_comments 'no GAWK present. AWK bundled with busybox is not posix compliant'
    fi
    ;;
  ${BL64_OS_MCOS}-*)
    BL64_TXT_CMD_AWK='/usr/bin/awk'
    BL64_TXT_CMD_BASE64='/usr/bin/base64'
    BL64_TXT_CMD_CUT='/usr/bin/cut'
    BL64_TXT_CMD_ENVSUBST='/opt/homebrew/bin/envsubst'
    BL64_TXT_CMD_GAWK="$BL64_VAR_UNAVAILABLE"
    BL64_TXT_CMD_GREP='/usr/bin/grep'
    BL64_TXT_CMD_FMT='/usr/bin/fmt'
    BL64_TXT_CMD_SED='/usr/bin/sed'
    BL64_TXT_CMD_SORT='/usr/bin/sort'
    BL64_TXT_CMD_TAIL='/usr/bin/tail'
    BL64_TXT_CMD_TR='/usr/bin/tr'
    BL64_TXT_CMD_UNIQ='/usr/bin/uniq'

    BL64_TXT_CMD_AWK_POSIX='/usr/bin/awk'
    ;;
  *) bl64_check_alert_unsupported ;;
  esac
}

#######################################
# Create command sets for common options
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function _bl64_txt_set_options() {
  bl64_dbg_lib_show_function

  # shellcheck disable=SC2034
  case "$BL64_OS_DISTRO" in
  ${BL64_OS_UB}-* | ${BL64_OS_DEB}-* | ${BL64_OS_KL}-*)
    BL64_TXT_SET_AWS_FS='-F'
    BL64_TXT_SET_GREP_ERE='-E'
    BL64_TXT_SET_GREP_INVERT='-v'
    BL64_TXT_SET_GREP_NO_CASE='-i'
    BL64_TXT_SET_GREP_QUIET='--quiet'
    BL64_TXT_SET_GREP_LINE='-x'
    BL64_TXT_SET_GREP_ONLY_MATCHING='-o'
    BL64_TXT_SET_GREP_SHOW_FILE_ONLY='-l'
    BL64_TXT_SET_GREP_STRING='-F'
    BL64_TXT_SET_GREP_STDIN='-'
    BL64_TXT_SET_SED_EXPRESSION='-e'
    BL64_TXT_SET_SED_INLINE='-i'
    BL64_TXT_SET_SORT_NATURAL='-V'
    BL64_TXT_SET_TAIL_LINES='-n'

    if [[ -x '/usr/bin/gawk' ]]; then
      BL64_TXT_SET_AWK_POSIX='--posix'
    fi
    ;;
  ${BL64_OS_FD}-* | ${BL64_OS_AMZ}-* | ${BL64_OS_CNT}-* | ${BL64_OS_RHEL}-* | ${BL64_OS_ALM}-* | ${BL64_OS_OL}-* | ${BL64_OS_RCK}-*)
    BL64_TXT_SET_AWK_POSIX='--posix'
    BL64_TXT_SET_AWS_FS='-F'
    BL64_TXT_SET_GREP_ERE='-E'
    BL64_TXT_SET_GREP_INVERT='-v'
    BL64_TXT_SET_GREP_NO_CASE='-i'
    BL64_TXT_SET_GREP_QUIET='--quiet'
    BL64_TXT_SET_GREP_LINE='-x'
    BL64_TXT_SET_GREP_ONLY_MATCHING='-o'
    BL64_TXT_SET_GREP_SHOW_FILE_ONLY='-l'
    BL64_TXT_SET_GREP_STRING='-F'
    BL64_TXT_SET_GREP_STDIN='-'
    BL64_TXT_SET_SED_EXPRESSION='-e'
    BL64_TXT_SET_SED_INLINE='-i'
    BL64_TXT_SET_SORT_NATURAL='-V'
    BL64_TXT_SET_TAIL_LINES='-n'
    ;;
  ${BL64_OS_SLES}-*)
    BL64_TXT_SET_AWK_POSIX='--posix'
    BL64_TXT_SET_AWS_FS='-F'
    BL64_TXT_SET_GREP_ERE='-E'
    BL64_TXT_SET_GREP_INVERT='-v'
    BL64_TXT_SET_GREP_NO_CASE='-i'
    BL64_TXT_SET_GREP_QUIET='-q'
    BL64_TXT_SET_GREP_LINE='-x'
    BL64_TXT_SET_GREP_ONLY_MATCHING='-o'
    BL64_TXT_SET_GREP_SHOW_FILE_ONLY='-l'
    BL64_TXT_SET_GREP_STRING='-F'
    BL64_TXT_SET_GREP_STDIN='-'
    BL64_TXT_SET_SED_EXPRESSION='-e'
    BL64_TXT_SET_SED_INLINE='-i'
    BL64_TXT_SET_SORT_NATURAL='-V'
    BL64_TXT_SET_TAIL_LINES='-n'
    ;;
  ${BL64_OS_ALP}-*)
    BL64_TXT_SET_AWK_POSIX=''
    BL64_TXT_SET_AWS_FS='-F'
    BL64_TXT_SET_GREP_ERE='-E'
    BL64_TXT_SET_GREP_INVERT='-v'
    BL64_TXT_SET_GREP_NO_CASE='-i'
    BL64_TXT_SET_GREP_QUIET='-q'
    BL64_TXT_SET_GREP_LINE='-x'
    BL64_TXT_SET_GREP_ONLY_MATCHING='-o'
    BL64_TXT_SET_GREP_SHOW_FILE_ONLY='-l'
    BL64_TXT_SET_GREP_STRING='-F'
    BL64_TXT_SET_GREP_STDIN='-'
    BL64_TXT_SET_SED_EXPRESSION='-e'
    BL64_TXT_SET_SED_INLINE='-i'
    BL64_TXT_SET_SORT_NATURAL='-V'
    BL64_TXT_SET_TAIL_LINES='-n'
    ;;
  ${BL64_OS_MCOS}-*)
    BL64_TXT_SET_AWK_POSIX=''
    BL64_TXT_SET_AWS_FS='-F'
    BL64_TXT_SET_GREP_ERE='-E'
    BL64_TXT_SET_GREP_INVERT='-v'
    BL64_TXT_SET_GREP_NO_CASE='-i'
    BL64_TXT_SET_GREP_QUIET='-q'
    BL64_TXT_SET_GREP_LINE='-x'
    BL64_TXT_SET_GREP_ONLY_MATCHING='-o'
    BL64_TXT_SET_GREP_SHOW_FILE_ONLY='-l'
    BL64_TXT_SET_GREP_STRING='-F'
    BL64_TXT_SET_GREP_STDIN='-'
    BL64_TXT_SET_SED_EXPRESSION='-e'
    BL64_TXT_SET_SED_INLINE='-i' # Warning: requires backup suffix
    BL64_TXT_SET_SORT_NATURAL='-V'
    BL64_TXT_SET_TAIL_LINES='-n'
    ;;
  *) bl64_check_alert_unsupported ;;
  esac

}
