If ((Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null) { Add-PSSnapin VMware.VimAutomation.Core }


## Variables
$vcenter = $args[0]
$cluster = $args[1]

## Gather RPools
Connect-VIServer $vcenter
[array]$rpools = Get-ResourcePool -Location (Get-Cluster $cluster)

## Enumerate Members of RPools
Foreach ($rpool in $rpools)
	{
	If ($rpool.name -ne "Resources")
		{
		[int]$percpushares = Read-Host "How many shares per CPU in the $($rpool.Name) resource pool?"
        [int]$perramshares = Read-Host "How many shares per MB RAM in the $($rpool.Name) resource pool?"
		$rpoolvms = $rpool | Get-VM
        $totalram = ($rpoolvms.MemoryMB | Measure-Object -sum).sum
        $totalcpu = ($rpoolvms.NumCPU | Measure-Object -sum).sum
        
		[int]$rpcpushares = $percpushares * $totalcpu
        [int]$rpramshares = $perramshares * $totalram
		Write-Host -ForegroundColor Green -BackgroundColor Black $rpool.name
		Write-Host "Found $totalvms in the $($rpool.name) resource pool, using $totalram MB RAM and $totalcpu vCPU's. This pool will be set to $rpramshares RAM shares and $rpcpushares CPU shares."
		Set-ResourcePool -ResourcePool $rpool.Name -CpuSharesLevel:Custom -NumCpuShares $rpshares -MemSharesLevel:Custom -NumMemShares $rpshares -Confirm:$true | Out-Null
		}
	}