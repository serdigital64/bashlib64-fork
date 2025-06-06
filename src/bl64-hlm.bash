#######################################
# BashLib64 / Module / Functions / Interact with HLM
#######################################

#######################################
# Add a helm repository to the local host
#
# Arguments:
#   $1: repository name
#   $2: repository source
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   0: operation completed ok
#   >0: operation failed
#######################################
function bl64_hlm_repo_add() {
  bl64_dbg_lib_show_function "$@"
  local repository="${1:-}"
  local source="${2:-}"

  bl64_check_parameter 'repository' &&
    bl64_check_parameter 'source' ||
    return $?

  bl64_msg_show_lib_subtask "add Helm repository (${repository} ${BL64_MSG_COSMETIC_LEFT_ARROW2} ${source})"
  bl64_hlm_run_helm \
    repo add \
    "$repository" \
    "$source" ||
    return $?

  bl64_msg_show_lib_subtask "update Helm repository catalog (${repository})"
  bl64_hlm_run_helm repo update "$repository"

  return 0
}

#######################################
# Upgrade or install helm existing chart
#
# * Using atomic and cleanup to ensure deployment integrity
#
# Arguments:
#   $1: full path to the kube/config file with cluster credentials
#   $2: target namespace
#   $3: chart name
#   $4: chart source
#   $@: arguments are passed as-is to the command
# Outputs:
#   STDOUT: command output
#   STDERR: command stderr
# Returns:
#   0: operation completed ok
#   >0: operation failed
#######################################
function bl64_hlm_chart_upgrade() {
  bl64_dbg_lib_show_function "$@"
  local kubeconfig="${1:-}"
  local namespace="${2:-}"
  local chart="${3:-}"
  local source="${4:-}"

    bl64_check_parameter 'namespace' &&
    bl64_check_parameter 'chart' &&
    bl64_check_parameter 'source' &&
    bl64_check_file "$kubeconfig" ||
    return $?

  bl64_lib_var_is_default "$kubeconfig" && kubeconfig=''

  shift
  shift
  shift
  shift

  bl64_msg_show_lib_subtask "deploy helm chart (${namespace}/${chart})"
  bl64_hlm_run_helm \
    upgrade \
    "$chart" \
    "$source" \
    ${kubeconfig:+--kubeconfig="$kubeconfig"} \
    --namespace "$namespace" \
    --timeout "$BL64_HLM_RUN_TIMEOUT" \
    --create-namespace \
    --atomic \
    --cleanup-on-fail \
    --install \
    --wait \
    "$@"
}

#######################################
# Command wrapper with verbose, debug and common options
#
# * Trust no one. Ignore inherited config and use explicit
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
function bl64_hlm_run_helm() {
  bl64_dbg_lib_show_function "$@"
  local verbosity=' '

  bl64_check_parameters_none "$#" &&
    bl64_check_module 'BL64_HLM_MODULE' ||
    return $?

  bl64_dbg_lib_command_is_enabled && verbosity="$BL64_HLM_SET_DEBUG"
  _bl64_hlm_harden_helm

  bl64_dbg_lib_trace_start
  # shellcheck disable=SC2086
  "$BL64_HLM_CMD_HELM" \
    $verbosity \
    "$@"
  bl64_dbg_lib_trace_stop
}

#######################################
# Remove or nullify inherited shell variables that affects command execution
#
# Arguments:
#   None
# Outputs:
#   STDOUT: None
#   STDERR: None
# Returns:
#   0: always ok
#######################################
function _bl64_hlm_harden_helm() {
  bl64_dbg_lib_show_function

  bl64_dbg_lib_show_info 'unset inherited HELM_* shell variables'
  bl64_dbg_lib_trace_start
  unset HELM_CACHE_HOME
  unset HELM_CONFIG_HOME
  unset HELM_DATA_HOME
  unset HELM_DEBUG
  unset HELM_DRIVER
  unset HELM_DRIVER_SQL_CONNECTION_STRING
  unset HELM_MAX_HISTORY
  unset HELM_NAMESPACE
  unset HELM_NO_PLUGINS
  unset HELM_PLUGINS
  unset HELM_REGISTRY_CONFIG
  unset HELM_REPOSITORY_CACHE
  unset HELM_REPOSITORY_CONFIG
  unset HELM_KUBEAPISERVER
  unset HELM_KUBECAFILE
  unset HELM_KUBEASGROUPS
  unset HELM_KUBEASUSER
  unset HELM_KUBECONTEXT
  unset HELM_KUBETOKEN
  bl64_dbg_lib_trace_stop

  return 0
}
