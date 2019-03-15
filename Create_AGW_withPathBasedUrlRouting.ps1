$subscription = "0013tbsdev08wrk"
$resourceGroup = "aaaaa"
$location = "canadacentral"

$agwName = "burakVNET2"

Connect-AzureRmAccount

Set-AzureRmContext -Subscription $subscription

# Create network resources

$backendSubnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
    -Name myBackendSubnet `
    -AddressPrefix 10.0.1.0/24
$agSubnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
    -Name myAGSubnet `
    -AddressPrefix 10.0.2.0/24
$vnet = New-AzureRmVirtualNetwork `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -Name $agwName `
    -AddressPrefix 10.0.0.0/16 `
    -Subnet $backendSubnetConfig, $agSubnetConfig
$pip = New-AzureRmPublicIpAddress `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -Name myAGPublicIPAddress `
    -AllocationMethod Dynamic

    
# Create IP configurations and frontend port
$vnet = Get-AzureRmVirtualNetwork `
    -ResourceGroupName $resourceGroup `
    -Name $agwName
$subnet = $vnet.Subnets[0]
$gipconfig = New-AzureRmApplicationGatewayIPConfiguration `
    -Name myAGIPConfig `
    -Subnet $subnet
$fipconfig = New-AzureRmApplicationGatewayFrontendIPConfig `
    -Name myAGFrontendIPConfig `
    -PublicIPAddress $pip
$frontendport = New-AzureRmApplicationGatewayFrontendPort `
    -Name myFrontendPort `
    -Port 80

# Create the backend pool and settings
$defaultPool = New-AzureRmApplicationGatewayBackendAddressPool `
    -Name appGatewayBackendPool

$app1Pool = New-AzureRmApplicationGatewayBackendAddressPool `
    -Name "app1Pool" `
    -BackendFqdns "burak-test.azure-websites.net"

$app2Pool = New-AzureRmApplicationGatewayBackendAddressPool `
    -Name "app2Pool" `
    -BackendFqdns "burak-test2.azure-websites.net"

$poolSettings = New-AzureRmApplicationGatewayBackendHttpSettings `
    -Name myPoolSettings `
    -Port 80 `
    -Protocol Http `
    -CookieBasedAffinity Enabled `
    -RequestTimeout 5

    
# Create the default listener and rule
$defaultlistener = New-AzureRmApplicationGatewayHttpListener `
    -Name mydefaultListener `
    -Protocol Http `
    -FrontendIPConfiguration $fipconfig `
    -FrontendPort $frontendport
$frontendRule = New-AzureRmApplicationGatewayRequestRoutingRule `
    -Name path-based `
    -RuleType PathBasedRouting `
    -HttpListener $defaultlistener `
    -BackendAddressPool $defaultPool `
    -BackendHttpSettings $poolSettings

# Create the application gateway
$sku = New-AzureRmApplicationGatewaySku `
    -Name "Standard_Small" `
    -Tier "Standard" `
    -Capacity 2
    
$appgw = New-AzureRmApplicationGateway `
    -Name myAppGateway `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -BackendAddressPools $defaultPool `
    -BackendHttpSettingsCollection $poolSettings `
    -FrontendIpConfigurations $fipconfig `
    -GatewayIpConfigurations $gipconfig `
    -FrontendPorts $frontendport `
    -HttpListeners $defaultlistener `
    -RequestRoutingRules $frontendRule `
    -Sku $sku 
