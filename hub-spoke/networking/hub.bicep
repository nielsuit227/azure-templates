param location string = 'switzerland'
param prefix string
param addressPrefix string
param firewallSubnetAddressPrefix string
param firewallManagementSubnetAddressPrefix string

// Hub VNet with Azure Firewall subnet
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: '${prefix}-hub'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallSubnetAddressPrefix
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: firewallManagementSubnetAddressPrefix
        }
      }

    ]
  }
}

output hubVnetName string = hubVnet.name
output hubVnetId string = hubVnet.id
