terraform {
    backend "s3" {
        bucket = "arnab-day08-statefilemgt"
        key    = "dev/terraform.tfstate"
        region = "ap-south-1"
        encrypt = true
        use_lockfile = true
    }
}