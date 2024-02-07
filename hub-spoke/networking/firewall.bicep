param location string
param prefix string
param hubVnetId string
param vmSubnetAddress string
param sqlServerFqdn string

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${prefix}-fwPublicIp'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}
resource managementPublicIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'myManagementPublicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: '${prefix}-hubFW'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Basic'
    }
    threatIntelMode: 'Alert'
    ipConfigurations: [
      {
        name: 'azureFirewallIpConfiguration'
        properties: {
          subnet: {
            id: '${hubVnetId}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    managementIpConfiguration: {
      name: 'managementIpConfiguration'
      properties: {
        publicIPAddress: {
          id: managementPublicIP.id
        }
        subnet: {
          id: '${hubVnetId}/subnets/AzureFirewallManagementSubnet'
        }
      }
    }
    applicationRuleCollections: [
      {
        name: 'AllowSqlServer'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'AllowAzureSql'
              description: 'Allow traffic to Azure SQL Database'
              sourceAddresses: [ vmSubnetAddress ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                sqlServerFqdn
              ]
            }
          ]
        }
      }
    ]
  }
}

output firewallPrivateIp string = azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
