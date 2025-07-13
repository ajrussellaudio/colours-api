data "archive_file" "lambda_deployment_package" {
  type        = "zip"
  output_path = "${path.module}/../dist/deployment.zip"
  source_dir  = "${path.module}/../"

  # Exclude files and directories that are not needed in the deployment package
  excludes = [
    ".git",
    ".github",
    "bruno",
    "terraform",
    ".gitignore",
    "prompt.md",
    "README.md"
  ]
}
