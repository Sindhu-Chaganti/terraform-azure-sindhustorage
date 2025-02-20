Version v0.1.0
<!-- BEGIN_TF_DOCS -->
## Creating Windows Azure Virtual Machine Scale Set
This module allows you to create Windows Virtual Machine Scale Set in Microsoft Azure.

## Changelog

-   Version `v0.1.0`
    * Published artifact name: `windowsvmss` 
    * Published artifact version: `0.1.0`

    ---

## Includes
-   main.tf
-   variables.tf
-   output.tf
-   README.md
-   versions.tf
-   example/main.tf
-   example/var-windowsvmss.auto.tfvars
-   example/provider.tf
-   example/variables.tf
-   example/windowsvmss-publish.yaml

## Features:
1. Creating Windows Virtual Machine Scale Set
2. Adding a manual autoscale setting to the Windows Virtual Machine Scale Set
3. Randomly generating password for virtual machine and storing it in a keyvault secret

## How to use?
* Azure DevOps:
    1. Copy `var-{module.name}.auto.tfvars` file in environment folder of your repository/branch. 
    2. Rename it to `var-${tfvars_file_name}.auto.tfvars` if required.
    3. Modify values of the attributes if required. And commit changes if any.
    4. Go-to `Pipline.{env}.yaml` file and add resource block if it is not there. And commit changes.
    5. Execute the pipeline by selecting `{tfvars_file_name}_plan` or `{tfvars_file_name}_apply` or both.
    
    ---

* GitLab:
    1. Copy contains of `example/main.tf` file
    2. Open gitlab. Move to required `{organization}/{project}/{subproject}/{dir_if_any}`.
    3. Create a new file say `main.tf`. Paste what you copied from `example/main.tf`
    4. Check source and modify value of attributes if required. Commit changes.
    5. Create a new file `provider.tf` in same directory and paste the contains of `example/provider.tf` there.
    6. Make required changes in `.gitlab-ci.yml` file and execute the pipeline.
    
    ---

* Local:
    1. Clone the repo to local.
    2. Make sure to setup terraform and environment paths correctly
    3. (For testing module) Open terminal inside example folder and run terraform commands provided below. (change `source = "../"`)
    4. (For using this module) Copy code from the example/main.tf, give path to the module in "source".
    6. Modify value of attributes if required.
    5. In same directory where module is being called, open terminal and run terraform commands provided below.
    6. Terraform commands: `terraform init` -> `terraform plan` -> `terraform apply`

    ---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | `1.1.9` |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | `3.3.0` |
| <a name="provider_random"></a> [random](#provider\_random) | `3.1.3` |

## Module Dependencies

* Module "resourcegroup" ("./modules/iac-tf-module-az-resource-group")
* Module "virtualnetwork" ("./modules/iac-tf-module-az-virtual-network")
* Module "subnet" ("./modules/iac-tf-module-az-subnet")
* Module "loadbalancer" ("./modules/iac-tf-module-az-load-balancer")
* Module "keyvault" ("./modules/iac-tf-module-az-keyvault")
* Module "diskencryptionset" ("./modules/iac-tf-module-az-diskencryptionset")

## Security Controls

| CATEGORY          | SECURITY STANDARD                                                                                                                                                             | SECURITY DEFINITION                                                                                                                                                                                                                                                  | REQUIRED?   |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| Access Management | Admininstrator Account                                                                                                                                                        | Ensures Admin access to VMSS Via username,password and ssh keys.                                                                                                                                                                                                     | Recommended    |
| Data Protection   | Encryption                                                                                                                                                                    | Ensure that VMss has encryption setting along with Os disk type.                                                                                                                                                                                                     | Recommended    |
| Data Protection   | Encryption at host                                                                                                                                                            | Ensure encryption at is enabled .                                                                                                                                                                                                                                    | Recommended    |
| Security          | Orchestration                                                                                                                                                                 | Scale set orchestration modes allow you to have greater control over how virtual machine instances are managed by the scale set                                                                                                                                      | Recommended    |
| Security          | Guest OS updates                                                                                                                                                              | Enabling automatic OS image upgrades on your scale set helps ease update management by safely and automatically upgrading the OS disk for all instances in the scale set                                                                                             | Recommended    |
| Security          | [automatic\_os\_upgrade\_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#automatic_os_upgrade_policy) | Ensure automatic\_os\_upgrade\_policy block is defined                                                                                                                                                                                                               | Recommended    |
| Data Protection   | boot\_diagnostics                                                                                                                                                             | Ensure Storage account URI is defined                                                                                                                                                                                                                                | Recommended    |
| Data Protection   | Certificate                                                                                                                                                                   | Ensure the URL is defined under the certicate block                                                                                                                                                                                                                  | Recommended    |
| Encryption   | data  Disk Encryption                                                                                                                                                             | Ensure disk encryption set id is provided | Recommended    |
| Security          | Extension                                                                                                                                                                     | Ensure auto\_upgrade\_minor\_version,automatic\_upgrade\_enabled and for sesitive information - protected\_settings are enabled                                                                                                                                      | Recommended    |
| Data Protection   | Network Interface - Networking                                                                                                                                                | Ensure network interface block is defined as per standards                                                                                                                                                                                                           | Recommended    |
| Security          | OS disk                                                                                                                                                                       | Ensure the OS disk is encrypted and block is defined                                                                                                                                                                                                                 | Recommended    |
| Access Management | terminate\_notification                                                                                                                                                       | Ensure this is enabled  and timeout length is between in minutes, (between 5 and 15).                                                                                                                                                                                | Recommended    |
| Security          | source\_image\_reference - Versioning                                                                                                                                         | Ensure this block is defined as per standards                                                                                                                                                                                                                        | Recommended    |
| Tags              | Tags                                                                                                                                                                          | Ensure mandatory tags are provided as per client requirements                                                                                                                                                                                                        | Recommended |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.password](https://registry.terraform.io/providers/hashicorp/azurerm/3.3.0/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.username](https://registry.terraform.io/providers/hashicorp/azurerm/3.3.0/docs/resources/key_vault_secret) | resource |
| [azurerm_monitor_autoscale_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.3.0/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_windows_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.3.0/docs/resources/windows_virtual_machine_scale_set) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/3.3.2/docs/resources/password) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.3.0/docs/data-sources/key_vault) | data source |
| [azurerm_lb.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.3.0/docs/data-sources/lb) | data source |
| [azurerm_lb_backend_address_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.3.0/docs/data-sources/lb_backend_address_pool) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.3.0/docs/data-sources/resource_group) | data source |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.3.0/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscale_settings"></a> [autoscale\_settings](#input\_autoscale\_settings) | n/a | <pre>map(object({<br>    autoscale_name    = string<br>    profile_name      = string<br>    vmss_name         = string<br>    default_instances = number<br>    minimum_instances = number<br>    maximum_instances = number<br>    rule = map(object({<br>      metric_name      = string<br>      time_grain       = string<br>      statistic        = string<br>      time_window      = string<br>      time_aggregation = string<br>      operator         = string<br>      threshold        = number<br>      direction        = string<br>      type             = string<br>      value            = string<br>      cooldown         = string<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_vmss"></a> [vmss](#input\_vmss) | n/a | <pre>map(object({<br>    name                            = string<br>    resource_group_name             = string<br>    key_vault_name                  = string<br>    key_vault_resource_group_name   = string<br>    sku                             = string<br>    instances                       = number<br>    zones                           = list(string)<br>    admin_username                  = string<br>    adminuser_key_vault_secret_name = string<br>    password_key_vault_secret_name  = string<br>    upgrade_mode                    = string<br>    rolling_upgrade_policy = object({<br>      max_batch_instance_percent              = number<br>      max_unhealthy_instance_percent          = number<br>      max_unhealthy_upgraded_instance_percent = number<br>      pause_time_between_batches              = string<br>    })<br>    source_image_id = string<br>    source_image_reference = object({<br>      publisher = string<br>      offer     = string<br>      sku       = string<br>      version   = string<br>    })<br>    os_disk_caching              = string<br>    os_disk_storage_account_type = string<br>    disk_encryption_set_id_os    = string<br>    data_disk = object({<br>      data_disk_lun                  = string<br>      data_disk_caching              = string<br>      data_disk_create_option        = string<br>      data_disk_size                 = string<br>      data_disk_storage_account_type = string<br>      disk_encryption_set_id_disk    = string<br>    })<br>    identiy_type                                 = string<br>    identity_ids                                 = list(string)<br>    enable_accelerated_networking                = bool<br>    enable_ip_forwarding                         = bool<br>    application_gateway_backend_address_pool_ids = list(string)<br>    application_security_group_ids               = list(string)<br>    lb_backend = object({<br>      lb_name                = string<br>      lb_backend_pool_name   = string<br>      lb_nat_pool_name       = string<br>      lb_probe_name          = string<br>      lb_resource_group_name = string<br>    })<br>    vnet_name                = string<br>    vnet_resource_group_name = string<br>    subnet_name              = string<br>    additional_tags          = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_linxuvmss_ids"></a> [linxuvmss\_ids](#output\_linxuvmss\_ids) | Specifies the Windows VMSS ID's |
<!-- END_TF_DOCS -->