setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "bl64_fs_check_new_dir: parameters are not present" {
  run bl64_fs_check_new_dir
  assert_failure
}