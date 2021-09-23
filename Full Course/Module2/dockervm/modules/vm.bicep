param vmName string
param adminPassword string
param subnetId string
param cloudInit string = '''
#cloud-config

packages:
 - build-essential
 - procps
 - file
 - linuxbrew-wrapper
 - docker.io

runcmd:
 - curl -sL https://aka.ms/InstallAzureCLIDeb | bash
 - az aks install-cli
 - systemctl start docker
 - systemctl enable docker
 - curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
 - chmod +x ./kind
 - mv ./kind /usr/bin
 
final_message: "cloud init was here"

'''

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'docker-ip'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Static'
    
  }
  sku: {
    name: 'Standard'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'dockernsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
           name: 'SSH'
           properties : {
               protocol : 'Tcp' 
               sourcePortRange :  '*'
               destinationPortRange :  '22'
               sourceAddressPrefix :  '*'
               destinationAddressPrefix: '*'
               access:  'Allow'
               priority : 1010
               direction : 'Inbound'
               sourcePortRanges : []
               destinationPortRanges : []
               sourceAddressPrefixes : []
               destinationAddressPrefixes : []
          }
      }      
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic'
  location: resourceGroup().location
  properties:{
    networkSecurityGroup: {
      id: nsg.id
    }
    ipConfigurations:[
      {
        name: 'ipConfig'
        properties:{
          subnet:{
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}



resource jumpbox 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: resourceGroup().location
  properties: {
    hardwareProfile:{
      vmSize: 'Standard_B8ms'
    }
    storageProfile:{
      imageReference:{
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk:{
        createOption: 'FromImage'
        managedDisk:{
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'azureuser'
      adminPassword: adminPassword
      linuxConfiguration:{
        disablePasswordAuthentication: false
      }
      customData: base64(cloudInit)
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: nic.id
          properties:{
            primary: true
          }
        }
      ]
    }
  }
}
