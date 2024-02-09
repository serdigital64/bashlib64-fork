setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  [[ -n "$container" ]] || skip 'requires container mode'
}

@test "bl64_cnt_check_not_in_container: check not ok" {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  run bl64_cnt_check_not_in_container
  assert_failure
}
