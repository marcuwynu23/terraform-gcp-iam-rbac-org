# terraform-gcp-iam-rbac-org

This Terraform project manages GCP IAM RBAC by assigning roles to Google Groups and managing group memberships. It uses GCS for remote state.

## Architecture

```mermaid
graph TD
    A[User] -->|terraform apply| B(Terraform)
    B -->|Auth via gcloud ADC| C{GCP API}
    B -->|Read/Write State| G[GCS Bucket]
    C -->|Update IAM Bindings| D[GCP Project IAM]
    C -->|Manage Group Memberships| E[Google Cloud Identity Groups]
```

### Sequence Diagram
```mermaid
sequenceDiagram
    participant U as User
    participant T as Terraform
    participant G as gcloud CLI
    participant API as GCP Cloud API
    participant GCS as GCS Bucket
    participant IAM as GCP Project IAM
    participant CI as Google Cloud Identity

    U->>G: gcloud auth application-default login
    G-->>U: Authentication Success
    U->>T: terraform apply
    T->>API: Authenticate using ADC
    T->>GCS: Read State
    T->>T: Plan Changes
    T->>IAM: Assign Roles to Groups
    T->>CI: Manage Group Memberships
    T->>GCS: Write State
    T-->>U: Complete
```

## Prerequisites

1. **Google Cloud SDK**: https://cloud.google.com/sdk/docs/install
2. **Terraform**: https://developer.hashicorp.com/terraform/downloads
3. **Google Cloud Organization & Google Groups**: This project assumes you already have an organization set up and the Google Groups (e.g., devops-team@yourdomain.com, dev-team@yourdomain.com) created. It manages IAM bindings and group memberships, but does not create the organization or groups themselves.

## Setup & Deployment

1. **Authenticate and Select Project**:
   This project uses your local `gcloud` credentials for authentication.

   ```bash
   # Authenticate
   gcloud auth application-default login

   # Select your project
   gcloud config set project your-project-id
   ```

2. **Configure Variables**:
   Create a `terraform.tfvars` file based on the example:

   ```hcl
   project_id       = "your-gcp-project-id"
   region            = "us-central1"
   backend_bucket   = "your-tfstate-bucket"
   backend_prefix    = "terraform-iam-rbac"

   team_permissions = {
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

   devops_group_name    = "devops-team@yourdomain.com"
   developer_group_name = "dev-team@yourdomain.com"

   devops_members = [
     "bob.ops@yourdomain.com",
     "charlie.ops@yourdomain.com"
   ]

   developer_members = [
     "alice.dev@yourdomain.com",
     "eve.dev@yourdomain.com"
   ]
   ```

3. **Create and Configure Backend Bucket (One-time)**:
   Create the GCS bucket for Terraform state and enable versioning (required for state locking):

   ```bash
   # Create the bucket (replace with your bucket name and region)
   gcloud storage buckets create gs://your-tfstate-bucket --location=us-central1

   # Enable versioning (required for state locking)
   gcloud storage buckets update gs://your-tfstate-bucket --versioning
   ```

4. **Initialize Backend (One-time)**:
   ```bash
   terraform init
   ```

5. **Validate Configuration**:

   ```bash
   terraform validate
   ```

6. **Plan Changes**:

   ```bash
   terraform plan
   ```

7.  **Apply Changes**:

    ```bash
    terraform apply
    ```

## Usage as a Module

Reference this repository as a Terraform module in your own configurations:

```hcl
module "iam_rbac_org" {
  source = "github.com/marcuwynu23/terraform-gcp-iam-rbac-org?ref=main"

  project_id = var.project_id
  region     = "us-central1"

  team_permissions = {
    "devops-team@yourdomain.com" = [
      "roles/compute.admin",
      "roles/run.admin",
      "roles/storage.admin"
    ],
    "dev-team@yourdomain.com" = [
      "roles/compute.viewer",
      "roles/run.developer"
    ]
  }

  devops_group_name    = "devops-team@yourdomain.com"
  developer_group_name = "dev-team@yourdomain.com"

  devops_members = [
    "bob@yourdomain.com",
    "charlie@yourdomain.com"
  ]

  developer_members = [
    "alice@yourdomain.com"
  ]
}
```

## Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `project_id` | GCP project ID | `string` | (required) |
| `region` | GCP region | `string` | `"us-central1"` |
| `backend_bucket` | GCS bucket for remote state | `string` | `"iammwwhobuild-tfstate-bucket"` |
| `backend_prefix` | Prefix in GCS bucket for state files | `string` | `"terraform-iam-rbac"` |
| `team_permissions` | Map of groups to their assigned GCP roles | `map(list(string))` | See defaults in `variables.tf` |
| `devops_members` | Users to add to the DevOps group | `list(string)` | See defaults in `variables.tf` |
| `developer_members` | Users to add to the Developer group | `list(string)` | See defaults in `variables.tf` |
| `devops_group_name` | DevOps Google Group name | `string` | `"devops-team@yourdomain.com"` |
| `developer_group_name` | Developer Google Group name | `string` | `"dev-team@yourdomain.com"` |
