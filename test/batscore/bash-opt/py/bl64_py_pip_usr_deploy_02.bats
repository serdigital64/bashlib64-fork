@test "bl64_py_pip_usr_install: install module - venv" {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  bl64_cnt_is_inside_container || skip 'test-case for container mode'

  bl64_py_setup
  run bl64_py_pip_usr_deploy

  assert_failure
}
