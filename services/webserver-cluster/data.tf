# PROJECT NAME: cspiner v1.0
#____________________________________________________
# PROJECT DESCRIPTION : Web Server Clusters With File Layout Isolation and file layout isolation: 
#____________________________________________________
# This file contains the main resources of the project
# Author: Kennedy .N
#____________________________________________________

#_________MODULE::::::data____________

#____________________________________________________

# Declare local Variables


data "aws_vpc" "default" {
  default = true
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket= var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-1"
  }
}