#Task-01: Understanding count
variable "arnab_day08_bucket" {
  description = "List of bucket names to create"
  type = list(string)
  default = [ "arnab-007-bucket1", "arnab-008-bucket2" ]
}

#Task-02: Understanding for_each
variable "arnab_bucket_set" {
  description = "Set of bucket names to cretae"
  type = set(string)
  default = [ "arnab-bucket-A", "arnab-bucket-B" ]
}