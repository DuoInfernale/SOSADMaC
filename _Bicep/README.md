# Break Glass Sign‑In Monitoring – Automated Deployment Guide

This document describes the required permissions, provider registrations, and deployment steps for deploying the Break Glass Sign‑In Monitoring solution using the Bicep templates in this repository. This guide is only designed to deploy the bicep files from your local machine and not via Azure DevOps or GitHub Actions.

The deployment includes:
- Resource Group creation  
- Log Analytics Workspace creation  
- Action Group creation  
- Scheduled Query Alert creation  
- Entra ID Diagnostic Settings targeting the Log Analytics Workspace  

Because the deployment uses **tenant‑level Entra ID Diagnostic Settings** and **subscription‑level Azure Monitor resources**, specific permissions and resource provider registrations are required.

## **IMPORTANT:** Change the placeholder of the subscription ID and USERNAME before running this script.

---

## 1. Authentication and Subscription Selection

```bash
az login
az account set --subscription "00000000-0000-0000-0000-000000000000"
```

## 2. Required Permissions (Least Privilege)

The deploying identity must have:
* **User Access Administrator:** Required to assign RBAC roles at the root management group.
* **Contributor or Owner:** Required because the ``` microsoft.aadiam/diagnosticSettings/write ``` operation can only be authorized at the tenant root scope ``` "/" ```, and Azure custom- or less privileged roles, with that specific right, cannot be assigned at this level.

Assign Contributor at the Root Management Group:
```bash
az role assignment list --scope "/"
az role assignment create --assignee "USERNAME" --role "Contributor" --scope "/"
```

### 2.1 Least‑Privilege Permissions for Log Analytics Workspace Deployment

The deployment identity needs:
* One custom minimal role allowing only Resource Group creation
* Azure Monitor roles required for Log Analytics Workspace creation and alert rule operations

#### 2.1.1 Create the custom role for Resource Group creation

```bash
az role definition create --role-definition "**/resource-group-creator.json"
```

#### 2.1.2 Assign required subscription-level roles

```bash
az role assignment list --scope "/subscriptions/00000000-0000-0000-0000-000000000000"
az role assignment create --assignee "USERNAME" --role "Custom Resource Group Creator" --scope "/subscriptions/00000000-0000-0000-0000-000000000000"
az role assignment create --assignee "USERNAME" --role "Monitoring Contributor" --scope "/subscriptions/00000000-0000-0000-0000-000000000000"
az role assignment create --assignee "USERNAME" --role "Log Analytics Contributor" --scope "/subscriptions/00000000-0000-0000-0000-000000000000"
```

## 3. Required Resource Providers

These Azure Resource Providers must be registered at the tenant level:

* ``` microsoft.aadiam ```
* ``` Microsoft.Insights ```
* ``` microsoft.operationalinsights ```

### 3.1 Check registration status

```bash
az provider show --namespace microsoft.aadiam --query "registrationState" -o tsv
az provider show --namespace Microsoft.Insights --query "registrationState" -o tsv
az provider show --namespace microsoft.operationalinsights --query "registrationState" -o tsv
```

### 3.2 Register if necessary

```bash
az provider register --namespace microsoft.aadiam
az provider register --namespace Microsoft.Insights
az provider register --namespace microsoft.operationalinsights
```

### 4. Validate Deployment (What‑If Mode)

```bash
az deployment tenant create \
  --location "Switzerland North" \
  --parameters "**/main.bicepparam" \
  --what-if
```

5. Execute Deployment

```bash
az deployment tenant create \
  --location "Switzerland North" \
  --parameters "**/main.bicepparam"
```

## Notes

* Contributor at the Root Management Group is required only because this tenant evaluates microsoft.aadiam/diagnosticSettings/write using Azure RBAC.
* The deployment identity must have both tenant‑scope and subscription‑scope permissions for the operation to succeed.
* Provider registration can take several minutes. Re-run the status checks until they report Registered.
* The deployment uses tenant-scoped ARM resources and subscription-scoped Azure Monitor resources, requiring permissions across both planes.

## Support and contributions

If you encounter any issues or have questions about the project, please contact the project maintainers. Feel free to submit pull requests to improve the project.

## License

This project is licensed under the [MIT License]().