resource "azurerm_monitor_action_group" "maingroup" {
  name                = "az-actiongroup"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "azactg"
  email_receiver {
    name = "sendtoadmin"
    email_address = var.email
  }
}

#cpu-utilization
resource "azurerm_monitor_metric_alert" "cpu-utilization" {
  name                = "example-metricalert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_virtual_machine.vm.id]
  description         = "Action will be triggered when CPU is greater than 60%."

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 60
    #when average cpu > 60% for 5 min(default)
  }


  action {
    action_group_id = azurerm_monitor_action_group.maingroup.id
  }
  depends_on = [ azurerm_resource_group.rg,azurerm_linux_virtual_machine.vm ]
}

#memory-utilization
  resource "azurerm_monitor_metric_alert" "memory-utilization" {
  name                = "example-metricalert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_virtual_machine.vm.id]
  description         = "Action will be triggered when Memmory is less than 20%"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 60
    #when available metrix bytes < 20% for 5 min(default)

  }

  action {
    action_group_id = azurerm_monitor_action_group.maingroup.id
  }
  depends_on = [ azurerm_resource_group.rg,azurerm_linux_virtual_machine.vm ]
}