#######################################
# BashLib64 / Module / Functions / OS / Identify OS attributes and provide command aliases
#######################################

#
# Deprecation aliases
#
# * Aliases to deprecated functions
# * Needed to maintain compatibility up to N-2 versions
#

function bl64_os_match() {
  bl64_msg_show_deprecated 'bl64_os_match' 'bl64_os_is_distro'
  bl64_os_is_distro "$@"
}
function bl64_os_match_compatible() {
  bl64_msg_show_deprecated 'bl64_os_match_compatible' 'bl64_os_is_compatible'
  bl64_os_is_compatible "$@"
}

#
# Internal functions
#

#######################################
# Identify and normalize Linux OS distribution name and version
#
# * Warning: bootstrap function
# * OS name format: OOO-V.V
#   * OOO: OS short name (tag)
#   * V.V: Version (Major, Minor)
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
function _bl64_os_set_distro() {
  bl64_dbg_lib_show_function
  if [[ -r '/etc/os-release' ]]; then
    _bl64_os_get_distro_from_os_release
  else
    _bl64_os_get_distro_from_uname
  fi
}

function _bl64_os_is_distro() {
  bl64_dbg_lib_show_function "$@"
  local check_compatibility="$1"
  local target="$2"
  local target_os=''
  local target_major=''
  local target_minor=''
  local current_major=''
  local current_minor=''

  if [[ "$target" == +([[:alpha:]])-+([[:digit:]]).+([[:digit:]]) ]]; then
    bl64_dbg_lib_show_info 'Analyze Pattern: match OS, Major and Minor'
    target_os="${target%%-*}"
    target_major="${target##*-}"
    target_minor="${target_major##*\.}"
    target_major="${target_major%%\.*}"
    current_major="${BL64_OS_DISTRO##*-}"
    current_minor="${current_major##*\.}"
    current_major="${current_major%%\.*}"
    bl64_dbg_lib_show_vars 'target_os' 'target_major' 'target_minor' 'current_major' 'current_minor'

    bl64_dbg_lib_show_info "[${BL64_OS_DISTRO}] == [${target_os}-${target_major}.${target_minor}]"
    if [[ "$BL64_OS_DISTRO" == ${target_os}-+([[:digit:]]).+([[:digit:]]) ]] &&
      ((current_major == target_major && current_minor == target_minor)); then
      :
    else
      if bl64_lib_flag_is_enabled "$check_compatibility" &&
        bl64_lib_mode_compability_is_enabled &&
        [[ "$BL64_OS_DISTRO" == ${target_os}-+([[:digit:]]).+([[:digit:]]) ]]; then
        return 1
      else
        return $BL64_LIB_ERROR_OS_NOT_MATCH
      fi
    fi

  elif [[ "$target" == +([[:alpha:]])-+([[:digit:]]) ]]; then
    bl64_dbg_lib_show_info 'Pattern: match OS and Major'
    target_os="${target%%-*}"
    target_major="${target##*-}"
    target_major="${target_major%%\.*}"
    current_major="${BL64_OS_DISTRO##*-}"
    current_major="${current_major%%\.*}"
    bl64_dbg_lib_show_vars 'target_os' 'target_major' 'current_major'

    bl64_dbg_lib_show_info "[${BL64_OS_DISTRO}] == [${target_os}-${target_major}]"
    if [[ "$BL64_OS_DISTRO" == ${target_os}-+([[:digit:]]).+([[:digit:]]) ]] &&
      ((current_major == target_major)); then
      :
    else
      if bl64_lib_flag_is_enabled "$check_compatibility" &&
        bl64_lib_mode_compability_is_enabled &&
        [[ "$BL64_OS_DISTRO" == ${target_os}-+([[:digit:]]).+([[:digit:]]) ]]; then
        return 1
      else
        return $BL64_LIB_ERROR_OS_NOT_MATCH
      fi
    fi

  elif [[ "$target" == +([[:alpha:]]) ]]; then
    bl64_dbg_lib_show_info 'Pattern: match OS ID'
    target_os="$target"

    bl64_dbg_lib_show_info "[${BL64_OS_DISTRO}] == [${target_os}]"
    [[ "$BL64_OS_DISTRO" == ${target_os}-+([[:digit:]]).+([[:digit:]]) ]] ||
      return $BL64_LIB_ERROR_OS_NOT_MATCH

  else
    bl64_msg_show_error "invalid OS pattern (${target})"
    return $BL64_LIB_ERROR_OS_TAG_INVALID
  fi

  return 0
}

#######################################
# Get normalized OS distro and version from uname
#
# * Warning: bootstrap function
# * Use only for OS that do not have /etc/os-release
# * Normalized data is stored in the global variable BL64_OS_DISTRO
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: os match
#   >0: error or os not recognized
#######################################
function _bl64_os_get_distro_from_uname() {
  bl64_dbg_lib_show_function
  local os_type=''
  local os_version=''
  local cmd_sw_vers='/usr/bin/sw_vers'

  os_type="$(bl64_os_get_type)"
  case "$os_type" in
  'Darwin')
    os_version="$("$cmd_sw_vers" -productVersion)" &&
      BL64_OS_DISTRO="$(_bl64_os_release_normalize "$os_version")" ||
      return $?

    BL64_OS_DISTRO="DARWIN-${BL64_OS_DISTRO}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_MACOS"
    bl64_dbg_lib_show_vars 'BL64_OS_DISTRO'
    ;;
  *)
    BL64_OS_DISTRO="$BL64_OS_UNK"
    bl64_msg_show_error \
      "BashLib64 not supported on the current OS. Please check the OS compatibility matrix for BashLib64 ($(uname -a))"
    return $BL64_LIB_ERROR_OS_INCOMPATIBLE
    ;;
  esac
  return 0
}

#######################################
# Get normalized OS distro and version from os-release
#
# * Warning: bootstrap function
# * Normalized data is stored in the global variable BL64_OS_DISTRO
# * Version is normalized to the format: OS_ID-V.S
#   * OS_ID: one of the OS standard tags
#   * V: Major version, number
#   * S: Minor version, number
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: os match
#   >0: error or os not recognized
#######################################
function _bl64_os_get_distro_from_os_release() {
  bl64_dbg_lib_show_function
  local version_normalized=''

  _bl64_os_release_load &&
    version_normalized="$(_bl64_os_release_normalize "$VERSION_ID")" ||
    return $?

  bl64_dbg_lib_show_info 'set BL_OS_DISTRO'
  case "${ID^^}" in
  'ALMALINUX')
    BL64_OS_DISTRO="${BL64_OS_ALM}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_REDHAT"
    ;;
  'ALPINE')
    BL64_OS_DISTRO="${BL64_OS_ALP}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_ALPINE"
    ;;
  'AMZN')
    BL64_OS_DISTRO="${BL64_OS_AMZ}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_FEDORA"
    ;;
  'CENTOS')
    BL64_OS_DISTRO="${BL64_OS_CNT}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_REDHAT"
    ;;
  'DEBIAN')
    BL64_OS_DISTRO="${BL64_OS_DEB}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_DEBIAN"
    ;;
  'FEDORA')
    BL64_OS_DISTRO="${BL64_OS_FD}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_FEDORA"
    ;;
  'DARWIN')
    BL64_OS_DISTRO="${BL64_OS_MCOS}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_MACOS"
    ;;
  'KALI')
    BL64_OS_DISTRO="${BL64_OS_KL}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_DEBIAN"
    ;;
  'OL')
    BL64_OS_DISTRO="${BL64_OS_OL}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_REDHAT"
    ;;
  'ROCKY')
    BL64_OS_DISTRO="${BL64_OS_RCK}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_REDHAT"
    ;;
  'RHEL')
    BL64_OS_DISTRO="${BL64_OS_RHEL}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_REDHAT"
    ;;
  'SLES')
    BL64_OS_DISTRO="${BL64_OS_SLES}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_SUSE"
    ;;
  'UBUNTU')
    BL64_OS_DISTRO="${BL64_OS_UB}-${version_normalized}"
    BL64_OS_FLAVOR="$BL64_OS_FLAVOR_DEBIAN"
    ;;
  *)
    bl64_msg_show_error \
      "current OS is not supported. Please check the OS compatibility matrix for BashLib64 (ID=${ID:-NONE} | VERSION_ID=${VERSION_ID:-NONE})"
    return $BL64_LIB_ERROR_OS_INCOMPATIBLE
    ;;
  esac
  bl64_dbg_lib_show_vars 'BL64_OS_DISTRO' 'BL64_OS_FLAVOR'
  return 0
}

function _bl64_os_release_load() {
  bl64_dbg_lib_show_function
  # shellcheck disable=SC1091
  bl64_dbg_lib_show_info 'parse /etc/os-release'
  if ! source '/etc/os-release' || [[ -z "$ID" || -z "$VERSION_ID" ]]; then
    bl64_msg_show_error 'failed to load OS information from /etc/os-release file'
    return $BL64_LIB_ERROR_TASK_FAILED
  fi
  bl64_dbg_lib_show_vars 'ID' 'VERSION_ID'
}

function _bl64_os_release_normalize() {
  bl64_dbg_lib_show_function "$@"
  local version_raw="$1"
  local version_normalized=''
  local version_pattern_single='^[0-9]+$'
  local version_pattern_major_minor='^[0-9]+\.[0-9]+$'
  local version_pattern_semver='^[0-9]+\.[0-9]+\.[0-9]+$'

  bl64_dbg_lib_show_info 'normalize OS version to match X.Y'
  if [[ "$version_raw" =~ $version_pattern_single ]]; then
    version_normalized="${version_raw}.0"
  elif [[ "$version_raw" =~ $version_pattern_major_minor ]]; then
    version_normalized="${version_raw}"
  elif [[ "$version_raw" =~ $version_pattern_semver ]]; then
    version_normalized="${version_raw%.*}"
  else
    version_normalized="$version_raw"bl64_os_is_compatible
  fi
  if [[ "$version_normalized" =~ $version_pattern_major_minor ]]; then
    echo "$version_normalized"
    return 0
  fi
  bl64_msg_show_error "unable to normalize OS version (${version_raw} != Major.Minor != ${version_normalized})"
  return $BL64_LIB_ERROR_TASK_FAILED
}

#
# Public functions
#

#######################################
# Compare the current OS against the provided flavor
#
# Arguments:
#   $1: flavor ID: BL64_OS_FLAVOR_*
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: flavor match
#   BL64_LIB_ERROR_OS_NOT_MATCH
#   BL64_LIB_ERROR_OS_TAG_INVALID
#######################################
function bl64_os_is_flavor() {
  bl64_dbg_lib_show_function "$@"
  local os_flavor="$1"

  bl64_check_module 'BL64_OS_MODULE' &&
    bl64_check_parameter 'os_flavor' ||
    return $?

  [[ "$BL64_OS_FLAVOR" == "$os_flavor" ]] && return 0
  return $BL64_LIB_ERROR_OS_NOT_MATCH
}

#######################################
# Compare the current OS version against a list of OS versions
#
# * There is a match if both distro and version are equal to any target on the list
#
# Arguments:
#   $@: each argument is an OS target. The list is any combintation of the formats: "$BL64_OS_<ALIAS>" "${BL64_OS_<ALIAS>}-V" "${BL64_OS_<ALIAS>}-V.S"
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: os match
#   BL64_LIB_ERROR_OS_NOT_MATCH
#   BL64_LIB_ERROR_OS_TAG_INVALID
#######################################
function bl64_os_is_distro() {
  bl64_dbg_lib_show_function "$@"
  local item=''
  local -i status=$BL64_LIB_ERROR_OS_NOT_MATCH

  bl64_check_module 'BL64_OS_MODULE' &&
    bl64_check_parameters_none $# ||
    return $?
  bl64_dbg_lib_show_info "Look for [BL64_OS_DISTRO=${BL64_OS_DISTRO}] in [OSList=${*}}]"
  # shellcheck disable=SC2086
  for item in "$@"; do
    _bl64_os_is_distro "$BL64_VAR_OFF" "$item"
    status=$?
    ((status == 0)) && break
  done
  return $status
}

#######################################
# Compare the current OS version against a list of compatible OS versions
#
# * Compatibility is only verified if BL64_LIB_COMPATIBILITY == ON
# * The OS is considered compatible if there is a Distro match, regardles of the version
#
# Arguments:
#   $@: each argument is an OS target. The list is any combintation of the formats: "$BL64_OS_<ALIAS>" "${BL64_OS_<ALIAS>}-V" "${BL64_OS_<ALIAS>}-V.S"
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: os match
#   BL64_LIB_ERROR_OS_NOT_MATCH
#   BL64_LIB_ERROR_OS_TAG_INVALID
#######################################
function bl64_os_is_compatible() {
  bl64_dbg_lib_show_function "$@"
  local item=''
  local -i status=$BL64_LIB_ERROR_OS_NOT_MATCH

  bl64_check_module 'BL64_OS_MODULE' &&
    bl64_check_parameters_none $# ||
    return $?
  bl64_dbg_lib_show_info "Look for exact match [BL64_OS_DISTRO=${BL64_OS_DISTRO}] in [OSList=${*}}]"
  # shellcheck disable=SC2086
  for item in "$@"; do
    _bl64_os_is_distro "$BL64_VAR_OFF" "$item"
    status=$?
    ((status == 0)) && break
  done
  if ((status != 0)); then
    bl64_dbg_lib_show_info "No exact match, look for compatibility"
    for item in "$@"; do
      _bl64_os_is_distro "$BL64_VAR_ON" "$item"
      status=$?
      if ((status == 0)); then
        break
      elif ((status == 1)); then
        bl64_msg_show_warning \
          "current OS version is not supported. Execution will continue since compatibility-mode was requested. (current-os: ${BL64_OS_DISTRO} ${BL64_MSG_COSMETIC_PIPE} supported-os: ${*}) ${BL64_MSG_COSMETIC_PIPE} caller: ${FUNCNAME[1]:-NONE}@${BASH_LINENO[1]:-NONE}.${FUNCNAME[2]:-NONE}@${BASH_LINENO[2]:-NONE})"
        status=0
        break
      fi
    done
  fi
  return $status
}

#######################################
# Determine if locale resources for language are installed in the OS
#
# Arguments:
#   $1: locale name
# Outputs:
#   STDOUT: None
#   STDERR: Validation errors
# Returns:
#   0: resources are installed
#   >0: no resources
#######################################
function bl64_os_lang_is_available() {
  bl64_dbg_lib_show_function "$@"
  local locale="$1"
  local line=''

  bl64_check_module 'BL64_OS_MODULE' &&
    bl64_check_parameter 'locale' &&
    bl64_check_command "$BL64_OS_CMD_LOCALE" ||
    return $?

  bl64_dbg_lib_show_info 'look for the requested locale using the locale command'
  IFS=$'\n'
  for line in $("$BL64_OS_CMD_LOCALE" "$BL64_OS_SET_LOCALE_ALL"); do
    unset IFS
    bl64_dbg_lib_show_info "checking [${line}] == [${locale}]"
    [[ "$line" == "$locale" ]] && return 0
  done

  return $BL64_LIB_ERROR_IS_NOT
}

#######################################
# Check the current OS version is in the supported list
#
# * Target use case is script compatibility. Use in the init part to halt execution if OS is not supported
# * Not recommended for checking individual functions. Instead, use if or case structures to support multiple values based on the OS version
# * The check is done against the provided list, exact match
# * Check is strict, ignores BL64_LIB_COMPATIBILITY global flag. If you need to check for compatibility, use bl64_os_check_compatibility() instead
# * This is a wrapper to the bl64_os_is_distro so it can be used as a check function
#
# Arguments:
#   $@: list of OS versions to check against. Format: same as bl64_os_is_distro
# Outputs:
#   STDOUT: None
#   STDERR: Error message
# Returns:
#   0: check ok
#   $BL64_LIB_ERROR_APP_INCOMPATIBLE
#######################################
function bl64_os_check_version() {
  bl64_dbg_lib_show_function "$@"

  bl64_os_is_distro "$@" && return 0

  bl64_msg_show_error \
    "task not supported by the current OS version (current-os: ${BL64_OS_DISTRO} ${BL64_MSG_COSMETIC_PIPE} supported-os: ${*}) ${BL64_MSG_COSMETIC_PIPE} caller: ${FUNCNAME[1]:-NONE}@${BASH_LINENO[1]:-NONE}.${FUNCNAME[2]:-NONE}@${BASH_LINENO[2]:-NONE})"
  return $BL64_LIB_ERROR_APP_INCOMPATIBLE
}

#######################################
# Check the current OS version is compatible against the supported list
#
# * Same as bl64_os_check_version() but obeys the global BL64_LIB_COMPATIBILITY flag
#
# Arguments:
#   $@: list of OS versions to check against. Format: same as bl64_os_is_distro
# Outputs:
#   STDOUT: None
#   STDERR: Error message
# Returns:
#   0: check ok
#   $BL64_LIB_ERROR_APP_INCOMPATIBLE
#######################################
function bl64_os_check_compatibility() {
  bl64_dbg_lib_show_function "$@"

  bl64_os_is_compatible "$@" && return 0

  bl64_msg_show_error \
    "task not supported by the current OS version (current-os: ${BL64_OS_DISTRO} ${BL64_MSG_COSMETIC_PIPE} supported-os: ${*}) ${BL64_MSG_COSMETIC_PIPE} caller: ${FUNCNAME[1]:-NONE}@${BASH_LINENO[1]:-NONE}.${FUNCNAME[2]:-NONE}@${BASH_LINENO[2]:-NONE})"
  return $BL64_LIB_ERROR_APP_INCOMPATIBLE
}

#######################################
# Command wrapper with verbose, debug and common options
#
# Arguments:
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   0: operation completed ok
#   >0: operation failed
#######################################
function bl64_os_run_sleep() {
  bl64_dbg_lib_show_function "$@"

  bl64_check_parameters_none "$#" &&
    bl64_check_module 'BL64_OS_MODULE' ||
    return $?

  bl64_dbg_lib_trace_start
  # shellcheck disable=SC2086
  "$BL64_OS_CMD_SLEEP" "$@"
  bl64_dbg_lib_trace_stop
}

#######################################
# Command wrapper with verbose, debug and common options
#
# * Trust no one. Ignore inherited config and use explicit config
#
# Arguments:
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   0: operation completed ok
#   >0: operation failed
#######################################
function bl64_os_run_getent() {
  bl64_dbg_lib_show_function "$@"

  bl64_check_parameters_none "$#" &&
    bl64_check_module 'BL64_OS_MODULE' &&
    bl64_check_command "$BL64_OS_CMD_GETENT" ||
    return $?

  bl64_dbg_lib_trace_start
  # shellcheck disable=SC2086
  "$BL64_OS_CMD_GETENT" \
    "$@"
  bl64_dbg_lib_trace_stop
}

#######################################
# Command wrapper with verbose, debug and common options
#
# * Trust no one. Ignore inherited config and use explicit config
#
# Arguments:
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   0: operation completed ok
#   >0: operation failed
#######################################
function bl64_os_run_date() {
  bl64_dbg_lib_show_function "$@"

  bl64_check_module 'BL64_OS_MODULE' &&
    bl64_check_command "$BL64_OS_CMD_DATE" ||
    return $?

  bl64_dbg_lib_trace_start
  # shellcheck disable=SC2086
  "$BL64_OS_CMD_DATE" \
    "$@"
  bl64_dbg_lib_trace_stop
}

#######################################
# Command wrapper with verbose, debug and common options
#
# * Trust no one. Ignore inherited config and use explicit config
#
# Arguments:
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   0: operation completed ok
#   >0: operation failed
#######################################
function bl64_os_run_cat() {
  bl64_dbg_lib_show_function "$@"

  bl64_check_module 'BL64_OS_MODULE' &&
    bl64_check_command "$BL64_OS_CMD_CAT" ||
    return $?

  bl64_dbg_lib_trace_start
  # shellcheck disable=SC2086
  "$BL64_OS_CMD_CAT" \
    "$@"
  bl64_dbg_lib_trace_stop
}

#######################################
# Check the current OS version is not in the unsupported list
#
# * Same as bl64_os_check_version, but for the opposite purpose
#
# Arguments:
#   $@: list of OS versions to check against. Format: same as bl64_os_is_distro
# Outputs:
#   STDOUT: None
#   STDERR: Error message
# Returns:
#   0: check ok
#   $BL64_LIB_ERROR_APP_INCOMPATIBLE
#######################################
function bl64_os_check_not_version() {
  bl64_dbg_lib_show_function "$@"

  bl64_os_is_distro "$@" || return 0

  bl64_msg_show_error \
    "task not supported by the current OS version (${BL64_OS_DISTRO})"
  return $BL64_LIB_ERROR_APP_INCOMPATIBLE
}

#######################################
# Command wrapper with verbose, debug and common options
#
# * Trust no one. Ignore inherited config and use explicit config
#
# Arguments:
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   0: operation completed ok
#   >0: operation failed
#######################################
function bl64_os_run_uname() {
  bl64_dbg_lib_show_function "$@"

  bl64_check_module 'BL64_OS_MODULE' &&
    bl64_check_command "$BL64_OS_CMD_CAT" ||
    return $?

  bl64_dbg_lib_trace_start
  # shellcheck disable=SC2086
  "$BL64_OS_CMD_UNAME" \
    "$@"
  bl64_dbg_lib_trace_stop
}
