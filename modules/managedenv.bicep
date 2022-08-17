param name string
param location string
param lawClientId string
@secure()
param lawClientSecret string
param infrastructureSubnetId string
param runtimeSubnetId string

resource env 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: lawClientId
        sharedKey: lawClientSecret
      }
    }
    vnetConfiguration: {
      dockerBridgeCidr: '10.2.0.1/16'
      infrastructureSubnetId: infrastructureSubnetId
      internal: false
      platformReservedCidr: '10.1.0.0/16'
      platformReservedDnsIP: '10.1.0.2'
      runtimeSubnetId: runtimeSubnetId
    }
    zoneRedundant: true
  }
}
output id string = env.id
