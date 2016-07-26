#Set Subscription Variables
Add-AzureAccount
$subscr = "AZURERMSUBSCRIPTION"

Get-AzureRmSubscription -SubscriptionName $subscr | Select-AzureRmSubscription

#Set Variables
$VMname = "VMNAME"
$VMRG =  "VIRTUALMACHINERESOURCEGROUP"
$NIC = "VIRTUALNICNAME"
$NicRG = "NICRESOURCEGROUP"

###################################################
#DO NOT edit below this point                     #
###################################################
#Get the VM
$VM = Get-AzureRmVM -Name $VMname -ResourceGroupName $VMRG
#Get the NIC
$NewNIC =  Get-AzureRmNetworkInterface -Name $NIC -ResourceGroupName $NICRG

#Add the NIC to the VM
$VM = Add-AzureRmVMNetworkInterface -VM $VM -Id $NewNIC.Id

#Reconfigure the VM
#NOTE ------- VM WILL BE RESTARTED!!!!!!!!!!!!!!!!!!!!
Update-AzureRmVM -VM $VM -ResourceGroupName $VMRG