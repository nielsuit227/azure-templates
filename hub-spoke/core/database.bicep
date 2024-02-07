param prefix string
param location string
param sqlServerName string
param databaseName string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string

resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: '${prefix}-${sqlServerName}'
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

output sqlServerId string = sqlServer.id
