param vnetName string
param vnetPrefix string
param defaultSubnetPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: resourceGroup().location
  properties:{
    addressSpace:{
      addressPrefixes:[
        vnetPrefix
      ]
    }
    subnets:[
      {
        name: 'default'
        properties:{
          addressPrefix: defaultSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
    
  }
}

    

output defaultSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'default')
output Id string = vnet.id