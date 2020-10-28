#
# Enable GuardDuty in this account.
# Important: this needs to be imported as GuardDuty is automatically
# when you set this account as a delegated admin.
#
resource "aws_guardduty_detector" "this" {
  provider                      = aws.main
  enable                        = var.guarduty_enabled
  finding_publishing_frequency  = var.guarduty_finding_publishing_frequency
}

# Set auto_enable to true if you want GuardDuty to be enabled in all of your
# organization member accounts
resource "aws_guardduty_organization_configuration" "this" {
  provider    = aws.main
  auto_enable = var.guardduty_organization_members_auto_enable
  detector_id = aws_guardduty_detector.this.id
}

#
# Define explicitly all GuardDuty enabled accounts
# Note: a lifecycle is used because email and invite trigger changes every time.
#
resource "aws_guardduty_member" "members" {
  provider    = aws.main
  for_each    = var.guardduty_member_accounts
  account_id  = can(each.value.account_id) ? each.value.account_id : null
  detector_id = aws_guardduty_detector.this.id
  email       = can(each.value.email) ? each.value.email : null
  invite      = can(each.value.invite) ? each.value.invite : false
  lifecycle {
    ignore_changes = [email, invite]
  }
}
