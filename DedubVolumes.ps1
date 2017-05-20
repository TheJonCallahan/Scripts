
Function Wait-GetDedupJob

{

    while ((Get-DedupJob).count -ne 0 )

    {

        Get-DedupJob

        Start-Sleep -Seconds 30

    }

}



foreach($item in Get-DedupVolume){

    Wait-GetDedupJob

    $item | Start-DedupJob -Type Optimization -Priority High -Memory 80

    Wait-GetDedupJob

    $item | Start-DedupJob -Type GarbageCollection -Priority High -Memory 80 -Full

    Wait-GetDedupJob

    $item | Start-DedupJob -Type Scrubbing -Priority High -Memory 80 -Full

    Wait-GetDedupJob

}

Get-DedupStatus
