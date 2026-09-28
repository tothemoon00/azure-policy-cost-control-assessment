# Azure Policy Cost-Control Assessment

This is my Azure Policy assessment project. It checks VM sizes against an approved list. I deployed the policy with Terraform and used GitHub Actions to validate the configuration and generate a plan.

I tested Deny mode in Azure Portal using a VM size outside the list. Azure rejected the request during validation with `RequestDisallowedByPolicy`. I then restored Audit mode and confirmed that Terraform reported no changes.

## What it does

The policy checks whether a resource is a virtual machine and its size is outside the allowed list:

- `Standard_B2s`
- `Standard_B2ms`
- `Standard_D2as_v5`

`Audit` is the default. It records noncompliance without blocking requests. `Deny` blocks requests for sizes outside the list. These sizes are examples for the assessment; a real allowlist would need to reflect workload needs and pricing.

Terraform manages three objects: an empty resource group, a custom policy definition, and an assignment scoped to that resource group. No VM is deployed by this configuration.

## How it is deployed

The policy rule and parameters are in `policy/`. `main.tf` creates the Azure objects, and `variables.tf` defines the settings. I used the Azure CLI login on my computer to deploy with Terraform.

For an initial deployment from PowerShell:

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and enter your subscription ID.
2. Sign in and select that subscription.
3. Generate a plan, check it with the script, and review the changes before applying.

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars before continuing.
az login
az account set --subscription '<subscription-id>'
terraform init
terraform validate
terraform plan -out .\assessment.tfplan
terraform show -json .\assessment.tfplan | Set-Content -Encoding utf8 .\assessment-plan.json
.\scripts\assert-zero-cost-plan.ps1 -PlanJsonPath .\assessment-plan.json
# Continue only if the check passes and you have reviewed the plan.
terraform apply .\assessment.tfplan
```

Applying a saved plan executes it without another confirmation prompt.

The plan check accepts exactly the three expected resource creations. It is an initial-deployment check, not an Azure cost calculator. It rejects updates, deletions, and no-change plans. For later changes, review `terraform plan` directly.

Terraform state is stored locally and excluded from Git. Keep the state so Terraform can manage and remove the deployment. Automatic Azure resource-provider registration is disabled in `providers.tf`.

## GitHub checks

- **Terraform validate** checks formatting and configuration validity.
- **Azure Terraform plan check** signs in through OIDC, generates a plan, and checks for the three expected creations. The Azure identity has Reader access and uses no client secret. This workflow does not deploy.

GitHub does not have my local Terraform state. Its plan starts from an empty state, so it is a configuration check, not a drift check of the existing deployment. I use a local `terraform plan` to compare the managed Azure resources with the configuration.

## What I tested

| Check | Result and limits |
| --- | --- |
| Terraform validation | The configuration is valid. This does not test policy enforcement. |
| Plan check | The initial plan contained only the three expected resource creations. |
| Azure Portal validation | With the assignment temporarily set to Deny, a request for `Standard_D2s_v5` returned `RequestDisallowedByPolicy` and named this assignment. Validation stopped before deployment. |
| Local plan after restoring Audit | Terraform reported `No changes`. |

I did not deploy an allowed VM or measure financial savings. An SKU allowlist does not limit the number of VMs or cap total spending.

## Next steps

For a shared deployment, I would add remote state, reviewed deployment approvals, and a deployment identity with permissions scoped to its work. Before wider enforcement, I would review Audit results with workload owners and test both allowed and disallowed requests.

When the demo is finished, run `terraform destroy` from the same directory with the local state still present. Review the proposed deletions before confirming.
