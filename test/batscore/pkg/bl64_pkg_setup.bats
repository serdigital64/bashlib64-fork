setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_pkg_setup: module setup" {
  run bl64_pkg_setup
  assert_success
}
