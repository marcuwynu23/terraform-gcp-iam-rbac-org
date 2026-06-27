variable "project_id" {
  description = "The GCP Project ID where IAM bindings will be applied."
  type        = string
}


variable "region" {
  description = "The GCP region for any regional resources (if needed)."
  type        = string
  default     = "us-central1"
}

variable "team_permissions" {
  description = "Map of team groups to their assigned GCP roles."
  type        = map(list(string))
  default = {
    "devops-team@yourdomain.com" = [
      "roles/compute.admin",
      "roles/run.admin",
      "roles/cloudbuild.admin",
      "roles/storage.admin"
    ],
    "dev-team@yourdomain.com" = [
      "roles/compute.viewer",
      "roles/run.developer",
      "roles/cloudbuild.editor",
      "roles/storage.objectUser"
    ]
  }
}

variable "devops_members" {
  description = "List of users to add to the DevOps group."
  type        = list(string)
  default = [
    "bob.ops@yourdomain.com",
    "charlie.ops@yourdomain.com"
  ]
}

variable "developer_members" {
  description = "List of users to add to the Developer group."
  type        = list(string)
  default = [
    "alice.dev@yourdomain.com",
    "eve.dev@yourdomain.com"
  ]
}

variable "devops_group_name" {
  description = "The DevOps Google Group name."
  type        = string
  default     = "devops-team@yourdomain.com"
}

variable "developer_group_name" {
  description = "The Developer Google Group name."
  type        = string
  default     = "dev-team@yourdomain.com"
}