setup() {
  . "$DEVBL_TEST_BASHLIB64"
  . "${DEVBL_BATS_HELPER}/bats-support/load.bash"
  . "${DEVBL_BATS_HELPER}/bats-assert/load.bash"
  . "${DEVBL_BATS_HELPER}/bats-file/load.bash"

}

@test "bl64_rxtx_env: public constants are set" {

  assert_equal "$BL64_RXTX_ERROR_BACKUP" 197
  assert_equal "$BL64_RXTX_ERROR_RESTORE" 198
  assert_equal "$BL64_RXTX_ERROR_TEMPORARY_REPO" 199
  assert_equal "$BL64_RXTX_ERROR_MISSING_PARAMETER" 200
  assert_equal "$BL64_RXTX_ERROR_MISSING_COMMAND" 201

}