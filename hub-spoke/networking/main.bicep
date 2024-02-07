param location string
param prefix string = 'hub-routing-test'
param sqlServerId string

param hubAddressPrefix string = '10.0.0.0/16'
param firewallSubnetAddressPrefix string = '10.0.1.0/24'
param firewallManagementSubnetAddressPrefix string = '10.0.2.0/24'

param vmSpokeAddressPrefix string = '10.1.0.0/16'
param vmSubnetAddressPrefix string = '10.1.1.0/24'

param dbSpokeAddressPrefix string = '10.2.0.0/16'
param dbSubnetAddressPrefix string = '10.2.1.0/24'

module hub './hub.bicep' = {
  name: 'vnetDeployment'
  params: {
    prefix: prefix
    location: location
    addressPrefix: hubAddressPrefix
    firewallSubnetAddressPrefix: firewallSubnetAddressPrefix
    firewallManagementSubnetAddressPrefix: firewallManagementSubnetAddressPrefix
  }
}

module routeTable './routeTable.bicep' = {
  name: 'routeTableDeployment'
  params: {
    prefix: prefix
    firewallPrivateIp: firewall.outputs.firewallPrivateIp
    databaseSubnetAddress: dbSubnetAddressPrefix
    location: location
  }
}

resource dbVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: '${prefix}-dbVnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ dbSpokeAddressPrefix ]
    }
    subnets: [
      {
        name: 'subnet0'
        properties: {
          addressPrefix: dbSubnetAddressPrefix
        }
      }
    ]
  }
}
module dbPeering './peering.bicep' = {
  name: 'dbPeering'
  params: {
    vnetOneName: hub.outputs.hubVnetName
    vnetTwoName: dbVnet.name
  }
}

resource vmVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: '${prefix}-vmVnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ vmSpokeAddressPrefix ]
    }
    subnets: [
      {
        name: 'subnet0'
        properties: {
          addressPrefix: vmSubnetAddressPrefix
          routeTable: {
            id: routeTable.outputs.routeTableId
          }
        }
      }
    ]
  }
}
module vmPeering './peering.bicep' = {
  name: 'vmPeering'
  params: {
    vnetOneName: hub.outputs.hubVnetName
    vnetTwoName: vmVnet.name
  }
}

resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  name: last(split(sqlServerId, '/'))
}

module firewall './firewall.bicep' = {
  name: 'firewallDeployment'
  params: {
    location: location
    prefix: prefix
    hubVnetId: hub.outputs.hubVnetId
    vmSubnetAddress: vmSubnetAddressPrefix
    sqlServerFqdn: '${sqlServer.name}.database.windows.net'
  }
  dependsOn: [
    hub
  ]
}

module sqlPrivateEndpoint './privateEndpoint.bicep' = {
  name: 'sqlPrivateEndpoint'
  params: {
    location: location
    prefix: prefix
    sqlServerId: sqlServerId
    subnetId: dbVnet.properties.subnets[0].id
  }
}

output dbSubnetId string = dbVnet.properties.subnets[0].id
output vmSubnetId string = vmVnet.properties.subnets[0].id
