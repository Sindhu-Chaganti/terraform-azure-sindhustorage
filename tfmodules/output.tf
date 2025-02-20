output "linxuvmss_ids" {
  value       = [for x in azurerm_windows_virtual_machine_scale_set.this : x.id]
  description = "Specifies the Windows VMSS ID's"
}