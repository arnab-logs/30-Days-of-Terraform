# Convert list to set to remove duplicates
locals {
  all_locations    = concat(var.user_locations, var.allowed_regions)
  unique_locations = toset(local.all_locations)

  # Number function examples
  monthly_costs     = [100, -50, 200, 75, -50]
  positive_costs    = [for c in local.monthly_costs : abs(c)]
  max_cost          = max(local.positive_costs...)
  min_cost          = min(local.positive_costs...)
  total_cost        = sum(local.positive_costs)
  average_cost      = local.total_cost / length(local.positive_costs)

  # Timestamp example
  current_time      = timestamp()
  formatted_time    = formatdate("DD-MM-YYYY HH:MM:SS", local.current_time)

  # File handling
  config_data = fileexists("config.json") ? jsondecode(file("config.json")) : {}
}
