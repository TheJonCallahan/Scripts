### Adapted from https://www.opsgility.com/blog/windows-azure-powershell-reference-guide/copying-vhds-blobs-between-storage-accounts/


### Source VHD ###
$srcURI =

### Target VHD Name ###
$destVHD =
 
### Source Storage Account ###
$srcStorageAccount =
$srcStorageKey = 
 
### Target Storage Account ###
$destStorageAccount = 
$destStorageKey = 
 
### Create the source storage account context ### 
$srcContext = New-AzureStorageContext  –StorageAccountName $srcStorageAccount `
                                        -StorageAccountKey $srcStorageKey  
 
### Create the destination storage account context ### 
$destContext = New-AzureStorageContext  –StorageAccountName $destStorageAccount `
                                        -StorageAccountKey $destStorageKey  
 
### Destination Container Name ### 
$containerName = "data"
 
### Create the container on the destination ### 
New-AzureStorageContainer -Name $containerName -Context $destContext 
 
### Start the asynchronous copy - specify the source authentication with -SrcContext ### 
$blob1 = Start-AzureStorageBlobCopy -srcURI $srcURI `
                                    -SrcContext $srcContext `
                                    -DestContainer $containerName `
                                    -DestBlob $destVHD`
                                    -DestContext $destContext

### Retrieve the current status of the copy operation ###
$status = $blob1 | Get-AzureStorageBlobCopyState 
 
### Print out status ### 
$status 
 
### Loop until complete ###                                    
While($status.Status -eq "Pending"){
  $status = $blob1 | Get-AzureStorageBlobCopyState 
  Start-Sleep 10
  ### Print out status ###
  $status
}
