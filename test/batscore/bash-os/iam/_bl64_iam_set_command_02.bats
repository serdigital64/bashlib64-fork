@test "_bl64_iam_set_command: commands are set" {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  bl64_iam_setup
  assert_not_equal "${BL64_IAM_CMD_ID}" ''
}

@test "_bl64_iam_set_command: commands are present" {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
  bl64_iam_setup
  assert_file_executable "${BL64_IAM_CMD_ID}"
}