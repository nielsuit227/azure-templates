param location string
param prefix string = 'routingTest'

var username = 'niels'
var password = 'Un28DRAthnf87#!'

module database 'core/database.bicep' = {
  name: 'databaseDeployment'
  params: {
    prefix: prefix
    location: location
    sqlServerName: '0'
    sqlAdministratorLogin: username
    sqlAdministratorLoginPassword: password
    databaseName: 'database'
  }
}
module networking 'networking/main.bicep' = {
  name: 'networkingDeployment'
  params: {
    prefix: prefix
    location: location
    sqlServerId: database.outputs.sqlServerId
  }
}
module vm 'core/vm.bicep' = {
  name: 'vmDeployment'
  params: {
    prefix: prefix
    location: location
    vmName: '0'
    vmAdminUsername: username
    vmAdminPassword: password
    subnetId: networking.outputs.vmSubnetId
  }
}
