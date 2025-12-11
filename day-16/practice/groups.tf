# Create IAM Groups

resource "aws_iam_group" "jedi_order" {
  name = "day-16-demo-Jedi-Order"
  path = "/day-16-demo/groups/"
}

resource "aws_iam_group" "sith_empire" {
  name = "day-16-demo-Sith-Empire"
  path = "/day-16-demo/groups/"
}

resource "aws_iam_group" "rebel_alliance" {
  name = "day-16-demo-Rebel-Alliance"
  path = "/day-16-demo/groups/"
}

resource "aws_iam_group" "galactic_senate" {
  name = "day-16-demo-Galactic-Senate"
  path = "/day-16-demo/groups/"
}


# Auto-Assign Users to Groups

resource "aws_iam_group_membership" "jedi_members" {
  name  = "day-16-demo-jedi-membership"
  group = aws_iam_group.jedi_order.name

  users = [
    for user in aws_iam_user.day_16_demo_users :
    user.name if user.tags.Department == "Jedi Order"
  ]
}

resource "aws_iam_group_membership" "sith_members" {
  name  = "day-16-demo-sith-membership"
  group = aws_iam_group.sith_empire.name

  users = [
    for user in aws_iam_user.day_16_demo_users :
    user.name if user.tags.Department == "Sith Empire"
  ]
}

resource "aws_iam_group_membership" "rebel_members" {
  name  = "day-16-demo-rebel-membership"
  group = aws_iam_group.rebel_alliance.name

  users = [
    for user in aws_iam_user.day_16_demo_users :
    user.name if user.tags.Department == "Rebel Alliance"
  ]
}

resource "aws_iam_group_membership" "senate_members" {
  name  = "day-16-demo-senate-membership"
  group = aws_iam_group.galactic_senate.name

  users = [
    for user in aws_iam_user.day_16_demo_users :
    user.name if user.tags.Department == "Galactic Senate"
  ]
}
