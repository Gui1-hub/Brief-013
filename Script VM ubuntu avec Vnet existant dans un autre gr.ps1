$VNET_RG="ASD-OCC-CoffresDeSauvegarde"
$VNET_NAME="ASD-OCC-VNET"
$SUBNET_NAME="GAE-Subnet"
$RG="GAE-B013"
$NIC_NAME="GAE-NIC-001"
$NSG_NAME="GAE-NSG-001"
$LOCATION="francecentral"
$SIZE="Standard_B4ms"
$IMAGE="Ubuntu2404"
$VM_NAME="GAE-VM-001"
$SSH_KEY="C:\Users\Utilisateur\.ssh\id_rsa.pub"
$PIP_NAME="GAE-PIP-001"

$SUBNET_ID=$(az network vnet subnet show --resource-group $VNET_RG --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)

# Create a resource group
az group create --name $RG --location $LOCATION

# Create Network Security Group and its rules
az network nsg create --resource-group $RG --name $NSG_NAME --location $LOCATION

az network nsg rule create --resource-group $RG --nsg-name $NSG_NAME --name "$NSG_NAME-SSH" --access Allow --protocol Tcp --direction Inbound --priority 100 --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22

$NSG_ID=$(az network nsg show --resource-group $RG --name $NSG_NAME --query id -o tsv)

az network public-ip create --resource-group $RG --name $PIP_NAME --location $LOCATION --allocation-method Static --sku Standard

$PUBLIC_IP_ID=$(az network public-ip show --resource-group $RG --name $PIP_NAME --query id -o tsv)

# Create a NIC and associate it to the NSG
az network nic create --resource-group $RG --name $NIC_NAME --vnet-name $VNET_NAME --subnet $SUBNET_ID --location $LOCATION --network-security-group $NSG_ID --public-ip-address $PUBLIC_IP_ID

$NIC_IP= $(az network nic show --resource-group $RG --name $NIC_NAME --query ipConfigurations[0].privateIpAddress -o tsv)

$NIC_ID=$(az network nic show --resource-group $RG --name $NIC_NAME --query id -o tsv)

# Create a VM
az vm create --resource-group $RG --name $VM_NAME --image $IMAGE --admin-username adminsimplon --admin-password P@ssw0rd34!!! --nics $NIC_ID --ssh-key-values $SSH_KEY --location $LOCATION --size $SIZE --storage-sku StandardSSD_LRS