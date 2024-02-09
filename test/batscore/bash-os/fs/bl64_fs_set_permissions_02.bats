setup() {
  DEV_TEST_INIT_ONLY='YES'
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  unset DEV_TEST_INIT_ONLY
  BATSLIB_TEMP_PRESERVE=0
  BATSLIB_TEMP_PRESERVE_ON_FAILURE=1

  TEST_SANDBOX="$(temp_make)"
  TEST_FILE="${TEST_SANDBOX}/test-file"
  touch "$TEST_FILE"
}

@test "bl64_fs_set_permissions: all defaults" {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  run bl64_fs_set_permissions \
    "$BL64_VAR_DEFAULT" \
    "$BL64_VAR_DEFAULT" \
    "$BL64_VAR_DEFAULT" \
    "$TEST_FILE"
  assert_success
}

@test "bl64_fs_set_permissions: set perm" {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  run bl64_fs_set_permissions \
    "0755" \
    "$BL64_VAR_DEFAULT" \
    "$BL64_VAR_DEFAULT" \
    "$TEST_FILE"
  assert_success
}

teardown() {
  temp_del "$TEST_SANDBOX"
}
