setup() {
  . "$DEVBL_TEST_SETUP"
}

@test "bl64_fs_find_files: required parameters. not path" {

  run bl64_fs_find_files '/fate/path'
  assert_failure

}