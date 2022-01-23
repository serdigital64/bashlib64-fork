#######################################
# BashLib64 / Write messages to logs
#
# Author: serdigital64 (https://github.com/serdigital64)
# License: GPL-3.0-or-later (https://www.gnu.org/licenses/gpl-3.0.txt)
# Repository: https://github.com/serdigital64/bashlib64
# Version: 1.1.0
#######################################

#######################################
# Save a log record to the logs repository
#
# Arguments:
#   $1: name of the function, command or script name that is generating the message
#   $2: log message category. Use any of $BL64_LOG_CATEGORY_*
#   $4: message to be saved to the logs repository
# Outputs:
#   STDOUT: None
#   STDERR: execution errors
# Returns:
#   0: log record successfully saved
#   >0: failed to save the log record
#   BL64_MSG_ERROR_INVALID_FORMAT
#######################################
function _bl64_log_register() {

  local source="$1"
  local category="$2"
  local payload="$3"

  if [[
    -z "$BL64_LOG_PATH" || \
    -z "$BL64_LOG_VERBOSE" || \
    -z "$BL64_LOG_TYPE" || \
    -z "$BL64_LOG_FS"
  ]]; then
    bl64_msg_show_error "$_BL64_LOG_TXT_NOT_SETUP"
    return $BL64_LOG_ERROR_NOT_SETUP
  fi

  case "$BL64_LOG_TYPE" in
  "$BL64_LOG_TYPE_FILE")
    printf '%(%d%m%Y%H%M%S)T%s%s%s%s%s%s%s%s%s%s%s%s\n' \
      '-1' \
      "$BL64_LOG_FS" \
      "$HOSTNAME" \
      "$BL64_LOG_FS" \
      "$BL64_SCRIPT_NAME" \
      "$BL64_LOG_FS" \
      "$BL64_SCRIPT_SID" \
      "$BL64_LOG_FS" \
      "${source}" \
      "$BL64_LOG_FS" \
      "$category" \
      "$BL64_LOG_FS" \
      "$payload" >>"$BL64_LOG_PATH"
    ;;
  *)
    bl64_msg_show_error "$_BL64_LOG_TXT_INVALID_TYPE"
    return $BL64_MSG_ERROR_INVALID_FORMAT
  esac

}

#######################################
# Initialize the log repository
#
# Arguments:
#   $1: full path to the log repository
#   $2: show log messages to STDOUT/STDERR?. 1: yes, 0: no
#   $3: log type. Use any of the constants $BL64_LOG_TYPE_*
#   $4: field separator character to be used on each log record
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: setup ok
#   BL64_MSG_ERROR_INVALID_FORMAT
#   BL64_MSG_ERROR_INVALID_VERBOSE
#######################################
function bl64_log_setup() {

  local path="$1"
  local verbose="${2:-1}"
  local type="${3:-$BL64_LOG_TYPE_FILE}"
  local fs="${4:-:}"

  # shellcheck disable=SC2086
  if [[ -z "$path" ]]; then
    bl64_msg_show_error "$_BL64_LOG_TXT_MISSING_PARAMETER"
    return $BL64_LOG_ERROR_MISSING_PARAMETER
  fi

  # shellcheck disable=SC2086
  if [[
    "$type" != "$BL64_LOG_TYPE_FILE"
  ]]; then
    bl64_msg_show_error "$_BL64_LOG_TXT_INVALID_TYPE"
    return $BL64_LOG_ERROR_INVALID_TYPE
  fi

  # shellcheck disable=SC2086
  if [[
    "$verbose" != '0' && \
    "$verbose" != '1'
  ]]; then
    bl64_msg_show_error "$_BL64_LOG_TXT_INVALID_VERBOSE"
    return $BL64_LOG_ERROR_INVALID_VERBOSE
  fi

  BL64_LOG_PATH="${path}" && \
  BL64_LOG_VERBOSE="${verbose}" && \
  BL64_LOG_TYPE="${type}" && \
  BL64_LOG_FS="${fs}"

}

#######################################
# Save a single log record of type 'info' to the logs repository.
# Optionally display the message on STDOUT (BL64_LOG_VERBOSE='1')
#
# Arguments:
#   $1: message to be recorded
#   $2: name of the function, command or script name that is generating the message
# Outputs:
#   STDOUT: message (when BL64_LOG_VERBOSE='1')
#   STDERR: execution errors
# Returns:
#   0: log record successfully saved
#   >0: failed to save the log record
#######################################
function bl64_log_info() {

  local payload="$1"
  local source="${2:-${FUNCNAME[1]}}"

  if [[ -n "$BL64_LOG_VERBOSE" && "$BL64_LOG_VERBOSE" == '1' ]]; then
    bl64_msg_show_info "$payload"
  fi

  _bl64_log_register \
    "${source:-main}" \
    "$BL64_LOG_CATEGORY_INFO" \
    "$payload"

}

#######################################
# Save a single log record of type 'task' to the logs repository.
# Optionally display the message on STDOUT (BL64_LOG_VERBOSE='1')
#
# Arguments:
#   $1: message to be recorded
#   $2: name of the function, command or script name that is generating the message
# Outputs:
#   STDOUT: message (when BL64_LOG_VERBOSE='1')
#   STDERR: execution errors
# Returns:
#   0: log record successfully saved
#   >0: failed to save the log record
#######################################
function bl64_log_task() {

  local payload="$1"
  local source="${2:-${FUNCNAME[1]}}"

  if [[ -n "$BL64_LOG_VERBOSE" && "$BL64_LOG_VERBOSE" == '1' ]]; then
    bl64_msg_show_task "$payload"
  fi

  _bl64_log_register \
    "${source:-main}" \
    "$BL64_LOG_CATEGORY_TASK" \
    "$payload"

}

#######################################
# Save a single log record of type 'error' to the logs repository.
# Optionally display the message on STDERR (BL64_LOG_VERBOSE='1')
#
# Arguments:
#   $1: message to be recorded
#   $2: name of the function, command or script name that is generating the message
# Outputs:
#   STDOUT: None
#   STDERR: execution errors, message (when BL64_LOG_VERBOSE='1')
# Returns:
#   0: log record successfully saved
#   >0: failed to save the log record
#######################################
function bl64_log_error() {

  local payload="$1"
  local source="${2:-${FUNCNAME[1]}}"

  if [[ -n "$BL64_LOG_VERBOSE" && "$BL64_LOG_VERBOSE" == '1' ]]; then
    bl64_msg_show_error "$payload"
  fi

  _bl64_log_register \
    "${source:-main}" \
    "$BL64_LOG_CATEGORY_ERROR" \
    "$payload"

}

#######################################
# Save a single log record of type 'warning' to the logs repository.
# Optionally display the message on STDERR (BL64_LOG_VERBOSE='1')
#
# Arguments:
#   $1: message to be recorded
#   $2: name of the function, command or script name that is generating the message
# Outputs:
#   STDOUT: None
#   STDERR: execution errors, message (when BL64_LOG_VERBOSE='1')
# Returns:
#   0: log record successfully saved
#   >0: failed to save the log record
#######################################
function bl64_log_warning() {

  local payload="$1"
  local source="${2:-${FUNCNAME[1]}}"

  if [[ -n "$BL64_LOG_VERBOSE" && "$BL64_LOG_VERBOSE" == '1' ]]; then
    bl64_msg_show_warning "$payload"
  fi

  _bl64_log_register \
    "${source:-main}" \
    "$BL64_LOG_CATEGORY_WARNING" \
    "$payload"

}

#######################################
# Record a log stream and save it to the logs repository.
# Each line is saved as a different log record.
#
# Arguments:
#   $1: short alphanumeric string to identify the log stream
#   $2: name of the function, command or script name that is generating the stream
# Outputs:
#   STDOUT: None
#   STDERR: execution errors
# Returns:
#   0: stream successfully saved
#   >0: failed to save the stream
#######################################
function bl64_log_record() {

  local tag="${1:-tag}"
  local source="${2:-${FUNCNAME[1]}}"
  local input_log_line=''

  case "$BL64_LOG_TYPE" in
  "$BL64_LOG_TYPE_FILE")
    while read -r input_log_line; do
      _bl64_log_register \
        "${source:-main}" \
        "$BL64_LOG_CATEGORY_RECORD" \
        "${tag}${BL64_LOG_FS}${input_log_line}"
    done
    ;;
  esac

}
