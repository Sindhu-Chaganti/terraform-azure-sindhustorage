variable "vmss" {
  type = map(object({
    name                            = string
    resource_group_name             = string
    key_vault_name                  = string
    key_vault_resource_group_name   = string
    sku                             = string
    instances                       = number
    zones                           = optional(list(string), null)
    admin_username                  = string
    adminuser_key_vault_secret_name = string
    password_key_vault_secret_name  = string
    upgrade_mode                    = optional(string, null)
    secret_activation_date          = optional(string, null)
    secret_expiration_date          = optional(string, null)
    rolling_upgrade_policy = object({
      max_batch_instance_percent              = number
      max_unhealthy_instance_percent          = number
      max_unhealthy_upgraded_instance_percent = number
      pause_time_between_batches              = string
    })
    source_image_id = optional(string, null)
    source_image_reference = object({
      publisher = optional(string, null)
      offer     = optional(string, null)
      sku       = optional(string, null)
      version   = optional(string, null)
    })
    os_disk_caching              = string
    os_disk_storage_account_type = string
    disk_encryption_set_id_os    = optional(string, null) 
    data_disk = object({
      data_disk_lun                  = string
      data_disk_caching              = string
      data_disk_create_option        = optional(string, null)
      data_disk_size                 = string
      data_disk_storage_account_type = string
      disk_encryption_set_id_disk    = optional(string, null)
    })
    identiy_type                                 = string
    identity_ids                                 = optional(list(string), null)
    enable_accelerated_networking                = optional(bool, null)
    enable_ip_forwarding                         = optional(bool, null)
    application_gateway_backend_address_pool_ids = optional(list(string), null)
    application_security_group_ids               = optional(list(string), null)
    lb_backend = object({
      lb_name                = optional(string, null)
      lb_backend_pool_name   = optional(string, null)
      lb_nat_pool_name       = optional(string, null)
      lb_probe_name          = optional(string, null)
      lb_resource_group_name = optional(string, null)
    })
    vnet_name                = string
    vnet_resource_group_name = string
    subnet_name              = string
    additional_tags          = map(string)
  }))
}
variable "autoscale_settings" {
  type = map(object({
    autoscale_name    = string
    profile_name      = string
    vmss_name         = string
    default_instances = number
    minimum_instances = number
    maximum_instances = number
    rule = map(object({
      metric_name      = string
      time_grain       = string
      statistic        = string
      time_window      = string
      time_aggregation = string
      operator         = string
      threshold        = number
      direction        = string
      type             = string
      value            = string
      cooldown         = string
    }))
  }))
}