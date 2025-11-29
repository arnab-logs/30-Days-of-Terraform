terraform {
    backend "s3" {
        bucket = "arnab-day06-statefilemgt"
        key    = "dev/terraform.tfstate"
        region = "ap-south-1"
        encrypt = true
        use_lockfile = true
    }
}