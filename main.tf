# ==========================================
# 1. TERRAFORM SETTINGS & REMOTE STATE LOCKING
# ==========================================
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }

  # This block forces Terraform to store the state centrally in GCS.
  # GCS automatically supports native state locking. If Engineer A runs 'apply',
  # GCS locks the file. If Engineer B tries to run 'apply' concurrently, 
  # Terraform will stop them and say "State locked!".
  backend "gcs" {} # Configure via -backend-config during init (see cd.yml)
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ==========================================
# 4. THE LOOPS AND DEPLOYMENT LOGIC
# ==========================================

# Flattens the multi-team map into an iterable list
locals {
  bindings = flatten([
    for group, roles in var.team_permissions : [
      for role in roles : {
        group = group
        role  = role
      }
    ]
  ])
}

# Globally binds roles to the Google Groups across the entire project
resource "google_project_iam_member" "global_multi_team_access" {
  for_each = {
    for b in local.bindings : "${b.group}-${b.role}" => b
  }

  project = var.project_id
  role    = each.value.role
  member  = "group:${each.value.group}"
}

# Loops through and assigns users to the DevOps Google Group
resource "google_cloud_identity_group_membership" "devops_users" {
  for_each = toset(var.devops_members)
  group    = "groups/${var.devops_group_name}"

  preferred_member_key {
    id = each.value
  }
  roles {
    name = "MEMBER"
  }
}

# Loops through and assigns users to the Developer Google Group
resource "google_cloud_identity_group_membership" "developer_users" {
  for_each = toset(var.developer_members)
  group    = "groups/${var.developer_group_name}"

  preferred_member_key {
    id = each.value
  }
  roles {
    name = "MEMBER"
  }
}