#Azure Account Variables
$subscr = "AZURERM"
$StorageAccountName = "AZURERMSTORAGEACCOUNT"
$StorageResourceGroup = "AZURESTORAGERESOURCEGROUP"

#set Azure Subscriptions and Storage Account Defaults
Get-AzureRmSubscription -SubscriptionName $subscr | Select-AzureRmSubscription -WarningAction SilentlyContinue
$StorageAccount = Get-AzureRmStorageAccount -name $StorageAccountName -ResourceGroupName $StorageResourceGroup | set-azurermstorageaccount -WarningAction SilentlyContinue

##Global Variables
$resourcegroupname = "AZURERESOURCEGROUPNAME"
$location = "AZURERMLOCATION"

## Compute Variables
$VMName = "AZURERMVIRTUALMACHINENAME"
$ComputerName = "AZUREMACHINENAME"
$VMSize = "AZURERMSIZE"
$OSDiskName = $VMName + "OSDisk"

## Network Variables
$Interface1Name = $VMName + "_int1"
$Interface2Name = $VMName + "_int2"
$Subnet1Name = "AZURERMSUBNET1"
$Subnet2Name = "AZURERMSUBNET2"
$VNetName = "AZURERMVNET"


###########################################################
#Do Not Edit Below This Point                             #
###########################################################

## Network Interface Creation
$PIp1 = New-AzureRmPublicIpAddress -Name $Interface1Name -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic -WarningAction SilentlyContinue
$VNet = Get-AzureRmVirtualNetwork -name $VNetName -ResourceGroupName $resourcegroupname -WarningAction SilentlyContinue
$Interface1 = New-AzureRmNetworkInterface -Name $Interface1Name -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[0].Id -PublicIpAddressId $PIp1.Id -WarningAction SilentlyContinue
$Interface2 = New-AzureRmNetworkInterface -Name $Interface2Name -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[0].Id -WarningAction SilentlyContinue

## Create VM Object
$Credential = Get-Credential
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest" -WarningAction SilentlyContinue
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -WarningAction SilentlyContinue
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface2.Id -WarningAction SilentlyContinue
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd" 
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage -WarningAction SilentlyContinue
$VirtualMachine.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true 

## Create the VM in Azure
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine -WarningAction SilentlyContinue
