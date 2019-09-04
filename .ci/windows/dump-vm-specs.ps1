# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2019 M. Riechert and D. Meyer. Licensed under the MIT License.

(Get-CimInstance Win32_OperatingSystem).Caption
(Get-CimInstance Win32_OperatingSystem).Version

Get-CimInstance Win32_Processor | 
    Select-Object Name, NumberOfCores, NumberOfLogicalProcessors | 
    Format-List

Write-Host "Working directory: $(pwd)"

Get-CimInstance -Class Win32_LogicalDisk |
    Where-Object {$_.DriveType -ne 5} |
    Select-Object Name, FileSystem, VolumeDirty, `
        @{"Label"="Size"; "Expression"={"{0:N} GB" -f ($_.Size/1GB)}}, `
        @{"Label"="Free"; "Expression"={"{0:N} GB" -f ($_.FreeSpace/1GB)}} |
    Format-Table -AutoSize

$total_physicalmem = Get-CimInstance -Class Win32_ComputerSystem | % {[Math]::round($_.TotalPhysicalMemory/1MB,0)} 
$physical_mem = Get-CimInstance -Class 'cim_physicalmemory' | % { "$($_.Capacity/1MB) MB" }

Write-Host "Physical memory         : "$physical_mem
Write-Host "Total physical memory   : "$total_physicalmem" MB"

Get-CimInstance Win32_OperatingSystem |
    Select-Object `
        @{"Label"="Free physical memory "; "Expression"={"{0} MB" -f ([Math]::round($_.FreePhysicalMemory/1024,0))}}, `
        @{"Label"="Free page file space "; "Expression"={"{0} MB" -f ([Math]::round($_.FreeSpaceInPagingFiles/1024,0))}}, `
        @{"Label"="Free virtual memory "; "Expression"={"{0} MB" -f ([Math]::round($_.FreeVirtualMemory/1024,0))}} |
    Format-List

$pagefile_managed = Get-CimInstance -Class Win32_ComputerSystem | % {$_.AutomaticManagedPagefile} 
$pagefile_usage = Get-CimInstance -Class Win32_PageFileUsage
$pagefile_settings = Get-CimInstance -Class Win32_PageFileSetting

Write-Host "Page file system managed : "$pagefile_managed  
Write-Host "Page file location       : "$pagefile_usage.Name
Write-Host "Page file current size   : "($pagefile_usage.AllocatedBaseSize | % { "$_ MB" })
Write-Host "Page file initial size   : "($pagefile_settings.InitialSize | % { "$_ MB" })
Write-Host "Page file maximum size   : "($pagefile_settings.MaximumSize | % { "$_ MB" })
