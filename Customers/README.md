# Usage

## Bicep

1. **Create a customer subfolder under `Customers` if it does not exist**:
   - Ensure there is a subfolder with the customer name under `Customers` in this repository. If it does not exist, create it.

2. **Create a customer pipeline and `main.bicepparam` from templates**:
   - Create a customer pipeline from `_Pipelines/_Templates/Customer Pipeline/tmpl-prod-customerpipeline-sosadmac-001.yml` under the customer folder.
   - Create a customer parameter file from `_Bicep/_Templates/main.bicepparam` under the customer folder.

3. **Define the variables in the customer pipeline**:
   - Define the required variables in the customer pipeline configuration to pass parameters to the template.
   - Use naming like `customerabbreviation-environment-customerpipeline-usage-xxx`, for example: `duo-prod-customerpipeline-sosadmac-001`.

4. **Copy files from `Customers/_Templates` (if available)**:
   - Copy required files from `Customers/_Templates` to the customer folder.

5. **Reference the template pipeline in the customer pipeline**:
   - Ensure the template pipeline is correctly referenced in the customer pipeline YAML.

6. **Create a service connection**:
   - Set up an Azure DevOps service connection for ARM federated workload identity.

7. **Create the Azure Pipeline for the customer**:
   - Create the pipeline in Azure DevOps using the customer pipeline YAML.
   - Validate first before running.

8. **Rename the Azure Pipeline**:
   - Rename the Azure Pipeline to match the customer pipeline file/pipeline naming.

9. **Run the Azure Pipeline**:
   - Execute the Azure Pipeline to deploy the configuration.

10. **Rerun the pipeline**:
    - Rerun the pipeline to confirm idempotent deployment and verify results.

## Notes

- Ensure you have the necessary permissions (at least Contributor) to create and manage pipelines in Azure DevOps.
- Verify all required variables and parameters are correctly defined in each customer pipeline configuration.
- Follow naming conventions and folder structure to keep customer onboarding consistent.
