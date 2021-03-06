targetScope='subscription'

// number of students
param students int = 1

// resource group parameters
param rgName string = 'rg-dockervm'
param location string = 'westeurope'

// vnet parameters
param vnetName string = 'docker-vnet'
param vnetPrefix string = '10.50.0.0/16'
param defaultSubnetPrefix string = '10.50.1.0/24'

// jumpbox parameters
param vmName string = 'docker-vm'

@secure()
param adminPassword string


// create resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgName
  location: location
}

module vnet 'modules/vnet.bicep' = {
  name: vnetName
  scope: rg
  params: {
    vnetName: vnetName
    vnetPrefix: vnetPrefix
    defaultSubnetPrefix: defaultSubnetPrefix
  }
}

module vm 'modules/vm.bicep' = [for i in range(0, students): {
  name: 'vmName-${i}'
  scope: rg
  params:{
    vmName: '${vmName}-${i}'
    subnetId: vnet.outputs.defaultSubnetId
    adminPassword: adminPassword
  }
}]


