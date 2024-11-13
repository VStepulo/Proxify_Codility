# Proxify_Codility

Task1:

Create a Terraform code to create a storage account (with container for blobs) and Service Bus queue.

These elements are connected together.


Requirements

1. Define a storage account named upload_storage_account in Terraform and uploadstorageaccount in Azure. The account tier should be Standard and replication should be LRS.

2. Define a storage container in the storage account created in step 1. It should be named upload_container in Terraform and upload-container in Azure. The container access type should be blob .

3. Define a Service Bus namespace named upload_queue_ns in Terraform and upload-queue-ns in Azure. The SKU should be set to Standard .

4. Define a Service Bus queue in the namespace created in step 3. It should be named upload_queue in Terraform and upload-queue in Azure. Partitioning should be enabled for this queue.

5. Create an Event Grid event subscription to connect everything together. It should be named upload_subscription in Terraform and upload-event-subscription in Azure:

	• It should use the upload_container created in step 2 as its scope.

	• It should reference the upload_queue endpoint. created in step 4 as its Service Bus queue endpoint.

	• It should be triggered on a Microsoft.Storage.BlobCreated event.

Assumptions

• You don't need to worry about any credentials for the cloud account; leave the provider definition as it is.

• Almost every resource in Azure needs a resource_group_name and a location parameter. Use azurerm_resource_group.rg.name and azurerm_resource_group.rg.location to specify them.

Hints

• Variable definitions are forbidden as they won't be provided to the command.

• Local variables are forbidden as they won't be expanded.

• terraform init is already executed in the environment.

• The code may not contain any syntax errors or warnings (e.g. regarding deprecations).

Available packages/libraries

• Terraform 0.15.0

• Azure Resource Manager Provider 2.56.0


Task2:

You must set up cloud infrastructure to host an application and a database deployment.

You must take a scalable and secure approach that uses a load balancer and bastion host.

You must implement the following requirements in Terraform.

Requirements

1. Define a virtual network named vnet with the 10.0.0.0/16 address space.

2. Define 3 subnets called AzureBastionSubnet (prefix 10.0.0.0/24), app_subnet (prefix 10.0.1.0/24), and db_subnet (prefix 10.0.2.0/24). All subnets should be defined outside the virtual network and reference its name.

3. Define 2 network interfaces called app_vm_interface and db_vm_interface with the same names for their respective IP configuration. The addresses should be allocated dynamically in their corresponding subnets.

4. Define 2 Linux virtual machines called app-vm and db-vm. Configure both VMs with admin username adminuser, and admin password adminPa$$word, reference their corresponding network interfaces' IDs, and reference the source image sku 20_04-1ts0.

5. Define 2 public IPs called public_ip_bastion and public_ip_lb. Both should be allocated statically and use Standard sku.

6. Define a bastion host named bastion with a Standard sku. Call the IP configuration bastion_config .

7. Define a load balancer named app_1b with a Standard sku. Call the frontend IP configuration app_1b_config.

8. Define a load balancer backend address pool named app_lb_backend_pool for the created load balancer.

9. Define a network interface backend address pool association named app_lb_association and match the app_vm_interface with the created backend pool.

10. Define 2 load balancer rules named app_tcp_80 and app_tcp_443 for the created load balancer and its backend address pool. The frontend and backend ports should match in each rule and refer to tcp ports 80 and 443, respectively.

Assumptions


• You don't need to worry about any credentials for the cloud account; leave the provider definition as it is.

• Almost every resource in Azure needs a resource_group_name and a location parameter. Use azurerm_resource_group.rg.name and azurerm_resource_group.rg.location to specify them.

• All resource names have to be the same in Terraform and Azure.

Hints

• terraform init is already executed in the environment.

• Variable definitions are forbidden as they won't be provided to the command.

• Local variables are forbidden as they won't be expanded.

• The code may not contain any syntax errors or warnings (for example, regarding deprecations).

Available packages/libraries

• Terraform 1.6.0

• Azure Resource Manager Provider 3.75.0
