#Login to Azure RM
Login-AzureRmAccount

$subscription = "0013tbsdev08wrk"
$resourceGroup = "aaaaa"

#Get list of azure service locations
#Get-AzureRmLocation | Format-Table

$location = "canadacentral"

#Set subscription
Set-AzureRmContext -SubscriptionName $subscription

#Create new VNet
$virtualNetwork = New-AzureRmVirtualNetwork `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -Name burakVNet `
    -AddressPrefix 10.0.0.0/16 

#Create subnet config
$subnetConfig = Add-AzureRmVirtualNetworkSubnetConfig `
    -Name myAppGWSubnet `
    -AddressPrefix 10.0.0.0/24 `
    -VirtualNetwork $virtualNetwork

#Associate the subnet to the virtual network
$virtualNetwork | Set-AzureRmVirtualNetwork

#Get the Application Gateway config
$gw = Get-AzureRmApplicationGateway -Name GatewayName -ResourceGroupName $resourceGroup

#Set the new virtual network and store the config into a new variable
$gw2 = Set-AzureRmApplicationGatewayIPConfiguration -SubnetId "/subscriptions/999999-9915-4b1c-accf-0c984bed2311/resourceGroups/RGName/providers/Microsoft.Network/virtualNetworks/NewVirtualNetwork/subnets/default" -ApplicationGateway $gw -Name $gw.GatewayIPConfigurations.name

#Stop the Gateway (you can't change the virtual network / subnet if the Gateway is running)
Stop-AzureRmApplicationGateway -ApplicationGateway $gw

#Set the new config
Set-AzureRmApplicationGateway -ApplicationGateway $gw2