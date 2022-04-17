setup() {
  . "$DEVBL_TEST_BASHLIB64"
  . "${DEVBL_BATS_HELPER}/bats-support/load.bash"
  . "${DEVBL_BATS_HELPER}/bats-assert/load.bash"
  . "${DEVBL_BATS_HELPER}/bats-file/load.bash"

}

@test "bl64_rbac_env: public constants are set" {
  assert_equal $BL64_RBAC_ERROR_MISSING_AWK 201
  assert_equal $BL64_RBAC_ERROR_MISSING_SUDOERS 202
  assert_equal $BL64_RBAC_ERROR_MISSING_VISUDO 203
  assert_equal $BL64_RBAC_ERROR_UPDATE_FAILED 210
  assert_equal $BL64_RBAC_ERROR_INVALID_SUDOERS 211
}