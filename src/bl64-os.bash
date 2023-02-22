#######################################
# BashLib64 / Module / Functions / OS / Identify OS attributes and provide command aliases
#
# Version: 1.18.0
#######################################

function _bl64_os_match() {
  bl64_dbg_lib_show_function "$@"
  local os="$1"
  local target="$2"
  local version="${target##*-}"

  if [[ "$target" == +([[:alpha:]])-+([[:digit:]]).+([[:digit:]]) ]]; then
    bl64_dbg_lib_show_info "Pattern: OOO-V.V [${BL64_OS_DISTRO}] == [${os}-${version}]"
    [[ "$BL64_OS_DISTRO" == "${os}-${version}" ]] || return $BL64_LIB_ERROR_OS_NOT_MATCH
  elif [[ "$target" == +([[:alpha:]])-+([[:digit:]]) ]]; then
    bl64_dbg_lib_show_info "Pattern: OOO-V [${BL64_OS_DISTRO}] == [${os}-${version}.+([[:digit:]])]"
    [[ "$BL64_OS_DISTRO" == ${os}-${version}.+([[:digit:]]) ]] || return $BL64_LIB_ERROR_OS_NOT_MATCH
  elif [[ "$target" == +([[:alpha:]]) ]]; then
    bl64_dbg_lib_show_info "Pattern: OOO [${BL64_OS_DISTRO}] == [${os}]"
    [[ "$BL64_OS_DISTRO" == ${os}-+([[:digit:]]).+([[:digit:]]) ]] || return $BL64_LIB_ERROR_OS_NOT_MATCH
  else
    bl64_msg_error "${_BL64_OS_TXT_INVALID_OS_PATTERN} (${target})"
    return $BL64_LIB_ERROR_OS_TAG_INVALID
  fi

  return 0
}

# Warning: bootstrap function
function _bl64_os_get_distro_from_uname() {
  bl64_dbg_lib_show_function
  local os_type=''
  local os_version=''
  local cmd_sw_vers='/usr/bin/sw_vers'

  os_type="$(uname)"
  case "$os_type" in
  'Darwin')
    os_version="$("$cmd_sw_vers" -productVersion)"
    BL64_OS_DISTRO="DARWIN-${os_version}"
    ;;
  *) BL64_OS_DISTRO="$BL64_OS_UNK" ;;
  esac

  if [[ "$BL64_OS_DISTRO" == "$BL64_OS_UNK" ]]; then
    bl64_msg_show_error "${_BL64_OS_TXT_OS_NOT_SUPPORTED} ($(uname -a))"
    return $BL64_LIB_ERROR_OS_INCOMPATIBLE
  fi
  bl64_dbg_lib_show_vars 'BL64_OS_DISTRO'

  return 0
}

# Warning: bootstrap function
function _bl64_os_get_distro_from_os_release() {
  bl64_dbg_lib_show_function

  # shellcheck disable=SC1091
  source '/etc/os-release'
  if [[ -n "${ID:-}" && -n "${VERSION_ID:-}" ]]; then
    BL64_OS_DISTRO="${ID^^}-${VERSION_ID}"
  fi

  case "$BL64_OS_DISTRO" in
  ${BL64_OS_ALM}-8*) : ;;
  ${BL64_OS_ALP}-3*) BL64_OS_DISTRO="${BL64_OS_ALP}-${VERSION_ID%.*}" ;;
  ${BL64_OS_CNT}-7*) [[ "$BL64_OS_DISTRO" == "${BL64_OS_CNT}-7" ]] && BL64_OS_DISTRO="${BL64_OS_CNT}-7.0" ;;
  ${BL64_OS_CNT}-8*) [[ "$BL64_OS_DISTRO" == "${BL64_OS_CNT}-8" ]] && BL64_OS_DISTRO="${BL64_OS_CNT}-8.0" ;;
  ${BL64_OS_CNT}-9*) [[ "$BL64_OS_DISTRO" == "${BL64_OS_CNT}-9" ]] && BL64_OS_DISTRO="${BL64_OS_CNT}-9.0" ;;
  ${BL64_OS_DEB}-9*) [[ "$BL64_OS_DISTRO" == "${BL64_OS_DEB}-9" ]] && BL64_OS_DISTRO="${BL64_OS_DEB}-9.0" ;;
  ${BL64_OS_DEB}-10*) [[ "$BL64_OS_DISTRO" == "${BL64_OS_DEB}-10" ]] && BL64_OS_DISTRO="${BL64_OS_DEB}-10.0" ;;
  ${BL64_OS_DEB}-11*) [[ "$BL64_OS_DISTRO" == "${BL64_OS_DEB}-11" ]] && BL64_OS_DISTRO="${BL64_OS_DEB}-11.0" ;;
  ${BL64_OS_FD}-33*) [[ "$BL64_OS_DISTRO" == "${BL64_OS_FD}-33" ]] && BL64_OS_DISTRO="${BL64_OS_FD}-33.0" ;;
  ${BL64_OS_FD}-34*) [[ "$BL64_OS_DISTRO" == "${BL64_OS_FD}-34" ]] && BL64_OS_DISTRO="${BL64_OS_FD}-34.0" ;;
  ${BL64_OS_FD}-35*) [[ "$BL64_OS_DISTRO" == "${BL64_OS_FD}-35" ]] && BL64_OS_DISTRO="${BL64_OS_FD}-35.0" ;;
  ${BL64_OS_FD}-36*) [[ "$BL64_OS_DISTRO" == "${BL64_OS_FD}-36" ]] && BL64_OS_DISTRO="${BL64_OS_FD}-36.0" ;;
  ${BL64_OS_OL}-7* | ${BL64_OS_OL}-8* | ${BL64_OS_OL}-9*) : ;;
  ${BL64_OS_RCK}-8*) : ;;
  ${BL64_OS_RHEL}-8* | ${BL64_OS_RHEL}-9*) : ;;
  ${BL64_OS_UB}-20* | ${BL64_OS_UB}-21* | ${BL64_OS_UB}-22*) : ;;
  *) BL64_OS_DISTRO="$BL64_OS_UNK" ;;
  esac

  if [[ "$BL64_OS_DISTRO" == "$BL64_OS_UNK" ]]; then
    bl64_msg_show_error "${_BL64_OS_TXT_FAILED_TO_NORMALIZE_OS} (ID=${ID:-NONE} | VERSION_ID=${VERSION_ID:-NONE}). ${_BL64_OS_TXT_CHECK_OS_MATRIX}"
    return $BL64_LIB_ERROR_OS_INCOMPATIBLE
  fi
  bl64_dbg_lib_show_vars 'BL64_OS_DISTRO'

  return 0
}

#######################################
# Check if the current OS matches the target list
#
# Arguments:
#   $@: each argument is an OS target. Any combintation of the formats: "$BL64_OS_<ALIAS>" "${BL64_OS_<ALIAS>}-V" "${BL64_OS_<ALIAS>}-V.S"
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: os match
#   BL64_LIB_ERROR_OS_NOT_MATCH
#   BL64_LIB_ERROR_OS_TAG_INVALID
#######################################
function bl64_os_match() {
  bl64_dbg_lib_show_function "$@"
  local item=''
  local -i status=$BL64_LIB_ERROR_OS_NOT_MATCH

  bl64_dbg_lib_show_info "Look for [BL64_OS_DISTRO=${BL64_OS_DISTRO}] in [OSList=${*}}]"
  # shellcheck disable=SC2086
  for item in "$@"; do
    case "$item" in
    "$BL64_OS_ALM" | ${BL64_OS_ALM}-*)
      _bl64_os_match "$BL64_OS_ALM" "$item"
      status=$?
      ;;
    "$BL64_OS_ALP" | ${BL64_OS_ALP}-*)
      _bl64_os_match "$BL64_OS_ALP" "$item"
      status=$?
      ;;
    "$BL64_OS_CNT" | ${BL64_OS_CNT}-*)
      _bl64_os_match "$BL64_OS_CNT" "$item"
      status=$?
      ;;
    "$BL64_OS_DEB" | ${BL64_OS_DEB}-*)
      _bl64_os_match "$BL64_OS_DEB" "$item"
      status=$?
      ;;
    "$BL64_OS_FD" | ${BL64_OS_FD}-*)
      _bl64_os_match "$BL64_OS_FD" "$item"
      status=$?
      ;;
    "$BL64_OS_MCOS" | ${BL64_OS_MCOS}-*)
      _bl64_os_match "$BL64_OS_MCOS" "$item"
      status=$?
      ;;
    "$BL64_OS_OL" | ${BL64_OS_OL}-*)
      _bl64_os_match "$BL64_OS_OL" "$item"
      status=$?
      ;;
    "$BL64_OS_RCK" | ${BL64_OS_RCK}-*)
      _bl64_os_match "$BL64_OS_RCK" "$item"
      status=$?
      ;;
    "$BL64_OS_RHEL" | ${BL64_OS_RHEL}-*)
      _bl64_os_match "$BL64_OS_RHEL" "$item"
      status=$?
      ;;
    "$BL64_OS_UB" | ${BL64_OS_UB}-*)
      _bl64_os_match "$BL64_OS_UB" "$item"
      status=$?
      ;;
    *)
      bl64_msg_error "${_BL64_OS_TXT_INVALID_OS_PATTERN} (${item})"
      return $BL64_LIB_ERROR_OS_TAG_INVALID ;;
    esac
    ((status == 0)) && break
  done

  # shellcheck disable=SC2086
  return $status
}

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
function bl64_os_get_distro() {
  bl64_dbg_lib_show_function
  if [[ -r '/etc/os-release' ]]; then
    _bl64_os_get_distro_from_os_release
  else
    _bl64_os_get_distro_from_uname
  fi
}
