locals {
  # Convert mission to lower case
  formatted_mission = lower(var.mission_terraform)

  # Format bucket name: lower case, replace spaces with hyphen, substring to 64 chars
  formatted_bucket_name = replace(lower(substr(var.bucket_name, 0, 64)), " ", "-")

  # Split allowed ports string into a list
  port_list = split(",", var.allowed_ports)

  # Create security group rules dynamically using for expression
  sg_rules = [
    for port in local.port_list : {
      name        = "port-${port}"
      port        = port
      description = "Allow port ${port}"
    }
  ]

  # Lookup instance size based on environment
  instance_size = lookup(var.instance_sizes, var.environment, "t2.micro")

  # Merge tags
  merged_tags = merge(var.default_tags, var.environment_tags)
}
