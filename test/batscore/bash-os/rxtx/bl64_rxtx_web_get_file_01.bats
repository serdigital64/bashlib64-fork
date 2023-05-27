setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_rxtx_web_get_file: function parameter missing" {
  run bl64_rxtx_web_get_file
  assert_failure
}

@test "bl64_rxtx_web_get_file: 2nd parameter is not present" {
  run bl64_rxtx_web_get_file '/dev/null'
  assert_failure
}