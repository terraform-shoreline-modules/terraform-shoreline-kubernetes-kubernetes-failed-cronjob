resource "shoreline_notebook" "kubernetes_cronjob_failure" {
  name       = "kubernetes_cronjob_failure"
  data       = file("${path.module}/data/kubernetes_cronjob_failure.json")
  depends_on = [shoreline_action.invoke_cronjob_schedule_validation,shoreline_action.invoke_cronjob_error_fix]
}

resource "shoreline_file" "cronjob_schedule_validation" {
  name             = "cronjob_schedule_validation"
  input_file       = "${path.module}/data/cronjob_schedule_validation.sh"
  md5              = filemd5("${path.module}/data/cronjob_schedule_validation.sh")
  description      = "Check the cronjob configuration to ensure that it is correctly defined and scheduled to run at the intended time."
  destination_path = "/tmp/cronjob_schedule_validation.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "cronjob_error_fix" {
  name             = "cronjob_error_fix"
  input_file       = "${path.module}/data/cronjob_error_fix.sh"
  md5              = filemd5("${path.module}/data/cronjob_error_fix.sh")
  description      = "Check for "100 missed start times" error. Recreate the cronjob if found."
  destination_path = "/tmp/cronjob_error_fix.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_cronjob_schedule_validation" {
  name        = "invoke_cronjob_schedule_validation"
  description = "Check the cronjob configuration to ensure that it is correctly defined and scheduled to run at the intended time."
  command     = "`chmod +x /tmp/cronjob_schedule_validation.sh && /tmp/cronjob_schedule_validation.sh`"
  params      = ["EXPECTED_SCHEDULE","NAMESPACE","CRONJOB_NAME"]
  file_deps   = ["cronjob_schedule_validation"]
  enabled     = true
  depends_on  = [shoreline_file.cronjob_schedule_validation]
}

resource "shoreline_action" "invoke_cronjob_error_fix" {
  name        = "invoke_cronjob_error_fix"
  description = "Check for "100 missed start times" error. Recreate the cronjob if found."
  command     = "`chmod +x /tmp/cronjob_error_fix.sh && /tmp/cronjob_error_fix.sh`"
  params      = ["NAMESPACE","CRONJOB_NAME","PATH_TO_CRONJOB_YAML"]
  file_deps   = ["cronjob_error_fix"]
  enabled     = true
  depends_on  = [shoreline_file.cronjob_error_fix]
}

