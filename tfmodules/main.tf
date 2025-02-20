data "azurerm_resource_group" "this" {
  for_each = var.vmss
  name     = each.value.resource_group_name
}

data "azurerm_virtual_network" "this" {
  for_each            = var.vmss
  name                = each.value["vnet_name"]
  resource_group_name = each.value["vnet_resource_group_name"]
}

data "azurerm_lb" "this" {
  for_each            = { for vm_k, vm_v in var.vmss : vm_k => vm_v if(vm_v.lb_backend.lb_name != null) }
  name                = each.value.lb_backend.lb_name
  resource_group_name = each.value.lb_resource_group_name
}

data "azurerm_lb_backend_address_pool" "this" {
  for_each        = { for vm_k, vm_v in var.vmss : vm_k => vm_v if(vm_v.lb_backend.lb_backend_pool_name != null) }
  loadbalancer_id = data.azurerm_lb.this[each.key].id
  name            = each.value.lb_backend.lb_backend_pool_name
}

data "azurerm_key_vault" "this" {
  for_each            = { for vm_k, vm_v in var.vmss : vm_k => vm_v if vm_v.key_vault_name != null }
  name                = each.value.key_vault_name
  resource_group_name = each.value.key_vault_resource_group_name
}

resource "azurerm_key_vault_secret" "username" {
  for_each     = { for vm_k, vm_v in var.vmss : vm_k => vm_v }
  name         = each.value.adminuser_key_vault_secret_name
  value        = each.value.admin_username
  key_vault_id = data.azurerm_key_vault.this[each.key].id
  content_type = "Admin Username VMSS"
  not_before_date = lookup(each.value, "secret_activation_date", null)
  expiration_date = lookup(each.value, "secret_expiration_date", timeadd(timestamp(), "8700h"))
  lifecycle {
    ignore_changes = [value]
  }
}

resource "random_password" "this" {
  for_each         = var.vmss
  length           = 12
  min_upper        = 1
  min_lower        = 1
  numeric          = true
  special          = true
  override_special = "!@#$%&."
}

resource "azurerm_key_vault_secret" "password" {
  for_each     = var.vmss
  name         = each.value.password_key_vault_secret_name
  value        = random_password.this[each.key].result
  key_vault_id = data.azurerm_key_vault.this[each.key].id
  content_type = "Admin Password VMSS"
  not_before_date = lookup(each.value, "secret_activation_date", null)
  expiration_date = lookup(each.value, "secret_expiration_date", timeadd(timestamp(), "8700h"))
  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "this" {
  for_each            = var.vmss
  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.this[each.key].name
  location            = data.azurerm_resource_group.this[each.key].location
  sku                 = each.value["sku"]
  instances           = each.value["instances"]
  zones               = each.value.zones
  admin_username      = each.value.admin_username
  admin_password      = random_password.this[each.key].result
  upgrade_mode        = each.value.upgrade_mode
  dynamic "rolling_upgrade_policy" {
    for_each = each.value.upgrade_mode == "Rolling" || each.value.upgrade_mode == "Automatic" ? [each.value.rolling_upgrade_policy] : []
    content {
      max_batch_instance_percent              = each.value.rolling_upgrade_policy.max_batch_instance_percent
      max_unhealthy_instance_percent          = each.value.rolling_upgrade_policy.max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = each.value.rolling_upgrade_policy.max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = each.value.rolling_upgrade_policy.pause_time_between_batches
    }
  }
  health_probe_id = each.value.upgrade_mode == "Rolling" || each.value.upgrade_mode == "Automatic" ? (each.value.lb_backend.lb_probe_name != null ? "${data.azurerm_lb.this[each.key].id}/probes/${each.value.lb_backend.lb_probe_name}" : null) : null
  source_image_id = each.value.source_image_id
  dynamic "source_image_reference" {
    for_each = each.value.source_image_id == null ? [each.value.source_image_reference] : []
    content {
      publisher = each.value.source_image_reference.publisher
      offer     = each.value.source_image_reference.offer
      sku       = each.value.source_image_reference.sku
      version   = each.value.source_image_reference.version
    }
  }
  os_disk {
    caching                = each.value.os_disk_caching
    storage_account_type   = each.value.os_disk_storage_account_type
    disk_encryption_set_id = each.value.disk_encryption_set_id_os
  }
  dynamic "data_disk" {
    for_each = each.value.data_disk != null ? [each.value.data_disk] : []
    content {
      lun                    = each.value.data_disk.data_disk_lun
      caching                = each.value.data_disk.data_disk_caching
      create_option          = each.value.data_disk.data_disk_create_option
      disk_size_gb           = each.value.data_disk.data_disk_size
      storage_account_type   = each.value.data_disk.data_disk_storage_account_type
      disk_encryption_set_id = each.value.data_disk.disk_encryption_set_id_disk
    }
  }
  identity {
    type         = each.value.identiy_type
    identity_ids = each.value.identity_ids
  }
  network_interface {
    name                          = "${each.key}-nic"
    primary                       = true
    enable_accelerated_networking = each.value.enable_accelerated_networking
    enable_ip_forwarding          = each.value.enable_ip_forwarding
    ip_configuration {
      name                                         = "${each.key}-nic-ip-config"
      application_gateway_backend_address_pool_ids = each.value.application_gateway_backend_address_pool_ids
      application_security_group_ids               = each.value.application_security_group_ids
      load_balancer_backend_address_pool_ids       = each.value.lb_backend.lb_backend_pool_name != null ? tolist(["${data.azurerm_lb.this[each.key].id}/backendAddressPools/${each.value.lb_backend.lb_backend_pool_name}"]) : null
      load_balancer_inbound_nat_rules_ids          = each.value.lb_backend.lb_nat_pool_name != null ? tolist(["${data.azurerm_lb.this[each.key].id}/inboundNatPools/${each.value.lb_backend.lb_nat_pool_name}"]) : null
      subnet_id                                    = "${data.azurerm_virtual_network.this[each.key].id}/subnets/${each.value["subnet_name"]}"
    }
  }
  tags = merge(each.value.additional_tags, data.azurerm_resource_group.this[each.key].tags)
}

locals {
  vmss = {
    for k, v in var.vmss : v.name => k
  }
}

resource "azurerm_monitor_autoscale_setting" "this" {
  for_each            = var.autoscale_settings
  name                = each.value.autoscale_name
  resource_group_name = data.azurerm_resource_group.this[local.vmss[each.value.vmss_name]].name
  location            = data.azurerm_resource_group.this[local.vmss[each.value.vmss_name]].location
  target_resource_id  = lookup(azurerm_windows_virtual_machine_scale_set.this, local.vmss[each.value["vmss_name"]])["id"]
  profile {
    name = each.value.profile_name
    capacity {
      default = each.value.default_instances
      minimum = each.value.minimum_instances
      maximum = each.value.maximum_instances
    }
    dynamic "rule" {
      for_each = each.value.rule
      content {
        metric_trigger {
          metric_name        = rule.value.metric_name
          metric_resource_id = lookup(azurerm_windows_virtual_machine_scale_set.this, local.vmss[each.value["vmss_name"]])["id"]
          time_grain         = coalesce(rule.value.time_grain, "PT1M")
          statistic          = coalesce(rule.value.statistic, "Average")
          time_window        = coalesce(rule.value.time_window, "PT5M")
          time_aggregation   = coalesce(rule.value.time_aggregation, "Average")
          operator           = coalesce(rule.value.operator, "GreaterThan")
          threshold          = coalesce(rule.value.threshold, "threshold")
        }
        scale_action {
          direction = rule.value.direction
          type      = rule.value.type
          value     = rule.value.value
          cooldown  = rule.value.cooldown
        }
      }
    }
  }
}