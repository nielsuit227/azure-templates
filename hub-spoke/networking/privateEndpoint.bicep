param location string
param prefix string
param sqlServerId string
param subnetId string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: '${prefix}-privateEndpoint'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${prefix}-privateEndpointSqlConnection'
        properties: {
          privateLinkServiceId: sqlServerId
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}
