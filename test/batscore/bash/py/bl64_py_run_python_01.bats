setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  [[ ! -x "$BL64_PY_CMD_PYTHON3" ]] && skip 'python3 not found'
  bl64_py_setup
}

@test "bl64_py_run_python: parameters are not present" {
  run bl64_py_run_python
  assert_failure
}