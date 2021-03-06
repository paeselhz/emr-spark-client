// Creating a bucket with the same name as the emr cluster
resource "aws_s3_bucket" "create_bucket" {
  bucket = var.name
  acl    = "private"

//  This will allow the bucket to be destroyed with the cluster
  force_destroy = true

  tags = {
    Name        = "Bucket for EMR Bootstrap actions/Steps"
    Environment = "Scripts"
  }
}

// This section of code should be uncommented if the user chooses to use a bootstrap action file
//resource "aws_s3_bucket_object" "bootstrap_action_file" {
//  bucket     = "${var.name}"
//  key        = "scripts/bootstrap_actions.sh"
//  source     = "scripts/bootstrap_actions.sh"
//  depends_on = ["aws_s3_bucket.create_bucket"]
//}

// The code below is responsible to copy the shell script
// that configures environment variables for RStudio
resource "aws_s3_bucket_object" "shell_script_cfg" {
  bucket     = var.name
  key        = "scripts/post-installation-cfg.sh"
  source     = "scripts/post-installation-cfg.sh"
  depends_on = [aws_s3_bucket.create_bucket]
}