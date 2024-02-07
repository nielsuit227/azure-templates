param prefix string
param firewallPrivateIp string
param databaseSubnetAddress string
param location string = resourceGroup().location

resource routeTable 'Microsoft.Network/routeTables@2020-07-01' = {
  name: '${prefix}-routeTable'
  location: location
  properties: {
    routes: [
      {
        name: 'routeToSqlDatabase'
        properties: {
          addressPrefix: databaseSubnetAddress
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
    ]
  }
}

output routeTableId string = routeTable.id
