setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_check_parameter: function parameter is not present" {

  run bl64_check_parameter
  assert_failure

}