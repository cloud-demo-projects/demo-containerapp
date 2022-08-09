param location string = resourceGroup().location
param envName string = 'containerapp-demo-nipun'

param containerImage string
param containerPort int
// param registry string
// param registryUsername string

// @secure()
// param registryPassword string

module law './modules/loganalyticsws.bicep' = {
    name: 'log-analytics-workspace'
    params: {
      location: location
      name: 'law-${envName}'
    }
}

module containerAppEnvironment './modules/managedenv.bicep' = {
  name: 'container-app-environment'
  params: {
    name: envName
    location: location
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerApp './modules/containerapp.bicep' = {
  name: 'sample'
  params: {
    name: 'sample-app'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    containerPort: containerPort
    // envVars: [
    //     {
    //     name: 'ASPNETCORE_ENVIRONMENT'
    //     value: 'Production'
    //     }
    // ]
    useExternalIngress: true
    // registry: registry
    // registryUsername: registryUsername
    // registryPassword: registryPassword

  }
}
output fqdn string = containerApp.outputs.fqdn
