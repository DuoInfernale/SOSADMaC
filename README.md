# SOSADMaC — Break Glass Sign‑In Monitoring

This repository contains infrastructure-as-code and pipeline assets for deploying the **Break Glass Sign‑In Monitoring** solution using Bicep templates. The deployment configures tenant- and subscription-scoped monitoring resources to capture and alert on "break glass" sign‑in activity in Entra ID.

This README provides an entry point and the common steps required to deploy the Break Glass solution. For the full, solution-specific deployment steps, refer to the README in the [`_Bicep`](./_Bicep) folder.

## Table of contents

- [Repository layout](#repository-layout)
- [Quick start](#quick-start)
- [Important pre-deployment notes](#important-pre-deployment-notes)
- [Authentication and subscription selection](#authentication-and-subscription-selection)
- [Required permissions (least privilege)](#required-permissions-least-privilege)
- [Required resource providers](#required-resource-providers)
- [Parameters and parameter file](#parameters-and-parameter-file)
- [Validate (What‑If) and execute tenant deployment](#validate-what-if-and-execute-tenant-deployment)
- [Post-deployment checks](#post-deployment-checks)
- [Troubleshooting & common issues](#troubleshooting--common-issues)
- [Security & best practices](#security--best-practices)
- [Support & contributions](#support--contributions)
- [License](#license)

## Repository layout

| Path | Description |
|------|-------------|
| `_Bicep` | Bicep templates for the Break Glass Sign‑In Monitoring solution and a dedicated README with detailed deployment instructions. |
| `_JSON` | (If present) ARM/JSON artifacts (legacy/alternate templates). |
| `_Pipelines` | CI/CD pipeline definitions for automated deployments. |
| `_Scripts` | Helper scripts (PowerShell / Bash) used by the deployment or for post-deploy tasks. |
| `Customers` | Customer-specific parameter files or pipeline variables. |
| `LICENSE` | Project license. |

## Quick start

1. Clone the repository:

   ```bash
   git clone <repo-url>
   ```

2. Open the Bicep solution README:

   ```bash
   cd _Bicep && less README.md   # or open in your editor
   ```

3. Authenticate to Azure and select the subscription used for subscription-scoped resources:

   ```bash
   az login
   az account set --subscription "00000000-0000-0000-0000-000000000000"
   ```

## Important pre-deployment notes

> [!IMPORTANT]
> Replace all placeholders in parameter files and scripts (subscription IDs, `USERNAME`/assignee, object IDs, passwords, regions) before running any deployment commands.

- The deployment includes **tenant-scoped** Entra ID diagnostic settings and **subscription-scoped** Azure Monitor resources. This requires permissions across both tenant and subscription scopes.
- **Do NOT** commit secrets (passwords, keys, connection strings) to source control. Use Azure Key Vault and references where possible.

## Authentication and subscription selection

```bash
az login
az account set --subscription "00000000-0000-0000-0000-000000000000"
```

## Required permissions (least privilege)

The deploying identity must have permissions across tenant and subscription scopes:

- **User Access Administrator** — required to assign RBAC roles at the root management group.
- **Contributor** (or **Owner**) at the root management group `/` — required because the `microsoft.aadiam/diagnosticSettings/write` operation is evaluated at tenant root scope and cannot be delegated via custom roles at a lower scope.

### Assign Contributor at the Root Management Group (example)

```bash
# Verify existing assignments on root scope
az role assignment list --scope "/"

# Assign Contributor to the deploying principal (replace USERNAME)
az role assignment create --assignee "USERNAME" --role "Contributor" --scope "/"
```

### Least‑privilege permissions for Log Analytics and Azure Monitor (subscription-level)

The deployment also creates subscription-scoped resources (resource groups, Log Analytics workspace, action groups, alert rules). The deploying identity needs roles at the target subscription:

- A minimal **custom role** that allows Resource Group creation (if you want to limit RBAC).
- **Monitoring Contributor** and **Log Analytics Contributor** roles for creating monitoring resources and alert rules.

### Create and assign a custom Resource Group creator role (example)

```bash
# Create the custom role from a local JSON definition
az role definition create --role-definition "./resource-group-creator.json"

# Assign roles at the subscription (replace SUBSCRIPTION_ID and USERNAME)
az role assignment create --assignee "USERNAME" --role "Custom Resource Group Creator" --scope "/subscriptions/00000000-0000-0000-0000-000000000000"
az role assignment create --assignee "USERNAME" --role "Monitoring Contributor"       --scope "/subscriptions/00000000-0000-0000-0000-000000000000"
az role assignment create --assignee "USERNAME" --role "Log Analytics Contributor"    --scope "/subscriptions/00000000-0000-0000-0000-000000000000"
```

## Required resource providers

Tenant/subscription-level deployments require the following resource providers to be registered:

- `microsoft.aadiam`
- `Microsoft.Insights`
- `microsoft.operationalinsights`

Check registration status:

```bash
az provider show --namespace microsoft.aadiam --query "registrationState" -o tsv
az provider show --namespace Microsoft.Insights --query "registrationState" -o tsv
az provider show --namespace microsoft.operationalinsights --query "registrationState" -o tsv
```

Register providers if necessary:

```bash
az provider register --namespace microsoft.aadiam
az provider register --namespace Microsoft.Insights
az provider register --namespace microsoft.operationalinsights
```

> [!NOTE]
> Provider registration can take several minutes. Re-run the status checks until they report `Registered`.

## Parameters and parameter file

- The Bicep deployment uses a parameters file (e.g. `main.bicepparam`). Edit the file and replace placeholders such as subscription IDs, usernames, and any environment-specific values.
- Ensure you do not place secrets in the parameter file — use Key Vault references when possible.

## Validate (What‑If) and execute tenant deployment

1. Use **What‑If** first to preview changes (tenant-scoped deployment example):

   ```bash
   az deployment tenant create \
     --location "Switzerland North" \
     --parameters "./main.bicepparam" \
     --what-if
   ```

2. Execute the tenant-scoped deployment:

   ```bash
   az deployment tenant create \
     --location "Switzerland North" \
     --parameters "./main.bicepparam"
   ```

> [!NOTE]
> - The deployment location is a deployment *operation* location and does not change resource regions inside the templates.
> - Choose an Azure region supported for tenant deployment operations (e.g. `switzerlandnorth`).

## Post-deployment checks

- [ ] Verify the Log Analytics workspace and configured diagnostic settings exist.
- [ ] Confirm action groups and scheduled query alerts are created and configured.
- [ ] Check Entra ID diagnostic settings are applied and target the Log Analytics workspace.
- [ ] Review role assignments and resource groups created by the deployment.

## Troubleshooting & common issues

| Issue | Resolution |
|-------|------------|
| `AuthorizationFailed` on `Microsoft.Authorization/roleAssignments/write` | Ensure the deploying principal has **User Access Administrator** or **Owner** where role assignments are being created. |
| `microsoft.aadiam/diagnosticSettings/write` failing | This operation is evaluated at tenant root — ensure **Contributor** (or **Owner**) at root scope `/` is assigned. |
| Provider registration pending | Re-check and wait until the state is `Registered`. |
| Missing or invalid parameters | Confirm all required fields (subscription IDs, names, prefixes) are present and valid in the `.bicepparam` file. |

## Security & best practices

- Never commit secrets to source control. Use Azure Key Vault and Key Vault references in parameter files.
- Use least-privilege RBAC roles. Where possible, use tailored custom roles that contain only the required permissions.
- Validate deployments using What‑If and test changes in non-production environments first.
- Review and audit any tenant-level permissions and role assignments applied during deployment.

## Support & contributions

- **Repository owner:** [Duo Infernale](https://github.com/duoinfernale)
- **Maintainers / Authors:** [Michele Blum](https://github.com/quattro99) & [Flavio Meyer](https://github.com/flaviomeyer)
- **Issues:** open an issue in this repository or contact the maintainers.
- **Contributions:** submit pull requests. Please avoid including secrets and follow any contribution guidelines in the repo.

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.
