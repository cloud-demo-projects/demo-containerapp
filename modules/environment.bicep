param name string
param location string
param lawClientId string
@secure()
param lawClientSecret string

resource env 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: name
  location: location
  properties: {
    //type: 'managed'
    //internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: lawClientId
        sharedKey: lawClientSecret
      }
    }
  }
}
output id string = env.id
