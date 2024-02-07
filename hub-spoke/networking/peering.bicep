param vnetOneName string
param vnetTwoName string

resource vnetOne 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetOneName
}
resource vnetTwo 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetTwoName
}

// Peering from one to two
resource peeringToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-01-01' = {
  name: '${vnetOne.name}-to-${vnetTwo.name}'
  parent: vnetOne
  properties: {
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: vnetTwo.id
    }
  }
}

// Peering from two to one
resource peeringFromHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-01-01' = {
  name: '${vnetTwo.name}-to-${vnetOne.name}'
  parent: vnetTwo
  properties: {
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: vnetOne.id
    }
  }
}
