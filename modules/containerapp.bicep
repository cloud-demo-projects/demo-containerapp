param location string
param name string
param containerAppEnvironmentId string
param containerImage string
param useExternalIngress bool = false
param containerPort int

param registry string
param registryUsername string
param envVars array = []

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {
      activeRevisionsMode:'Multiple'
      secrets: [
        {
          name: 'service-bus-connection-string'
          value: 'Endpoint=sb://servicebus-ns-demo.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=A56XKf0oNyU/Ov7G1kK5l0SFBVyqFCLJnb+QROVyjEQ='
        }
        {
          name: 'container-registry-password'
          value: 'IeqFaL4FNTN6v1LTOqpF54i6+ap87QjV'
        }
      ]
      registries: [
        {
          identity: '/subscriptions/3a89d508-f992-4729-9058-ba4fae9a35ca/resourcegroups/sandbox-nl02918-1656933641-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/containerappdemo-umi'
          server: registry
          username: registryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: name
          env: envVars
          probes: [
            {
              failureThreshold: 5
              httpGet: {
                path: '/'
                port: 80
              }
              initialDelaySeconds: 10
              periodSeconds: 5
              type: 'liveness'
            }
            {
              tcpSocket: {
                port: 80
              }
              initialDelaySeconds: 10
              periodSeconds: 5
              type: 'readiness'
            }
          ]
          resources: {
            cpu: 1
            memory: '2Gi'
          }
          volumeMounts: [
            {
              mountPath: '/myempty'
              volumeName: 'myempty'
            }
            {
              mountPath: '/fileshare'
              volumeName: 'my-azure-file-volume'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
        rules: [
          {
            http: {
              metadata: {
                concurrentRequests: '1'
              }
            }
            name: 'http-trigger'
          }
          {
            custom: {
              auth: [
                {
                  secretRef: 'service-bus-connection-string'
                  triggerParameter: 'connection'
                }
              ]
              metadata: {
                queueName: 'myservicebusqueue'
                messageCount: '20'
              }
              type: 'azure-servicebus'
            }
            name: 'queue-based-autoscaling'
          }
          {
            custom: {
              metadata: {
                type: 'Utilization'
                value: '1'
              }
              type: 'cpu'
            }
            name: 'cpu-scaling-rule'
          }
          {
            custom: {
              metadata: {
                type: 'Utilization'
                value: '1'
              }
              type: 'memory'
            }
            name: 'memory-scaling-rule'
          }
        ]
      }
      volumes: [
        {
          name: 'myempty'
          storageType: 'EmptyDir'
        }
        {
          name: 'my-azure-file-volume'
          storageName: 'mystoragemount'
          storageType: 'AzureFile'
        }
      ]
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
