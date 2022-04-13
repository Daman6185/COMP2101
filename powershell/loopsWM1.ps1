echo "____________system hardware discription_____________"
function hardwaredescription {
 get-wmiobject -class win32_computersystem |
 foreach {
          new-object -TypeName psobject -property @{
                 domain = $_.Domain
                 manufacturer = $_.Manufacturer
                 model = $_.Model
                 name = $_.Name
                 primaryOwnername = $_.PrimaryOwnerName
                 "totalphysicalmemory(MB)" = $_.TotalPhysicalMemory/1mb
          }
 }|  Format-list domain,manufacturer,model,name,primaryOwnername,"totalphysicalmemory(MB)"

 }
 hardwaredescription

 echo "____________________-operating system name and version number___________________________"

 function OSnameversion {
 get-wmiobject -class win32_operatingsystem |
 foreach {
          new-object -TypeName psobject -property @{
                 versionnumber = $_.Version
                 name = $_.Name
          }
 }|  Format-list name,versionnumber


 }
 OSnameversion

 echo "___________________processor description with speed, number of cores, and sizes__________________"

 function processordescription {

  get-wmiobject -class win32_processor |
 foreach {
          new-object -TypeName psobject -property @{
                 speed = $_.MaxClockSpeed
                 numberofCores = $_.NumberOfCores
                 description = $_.Description
                 sizeofL3 = $_.L3CacheSize
                 speedofL3 = $_.L3CacheSpeed
          }
 }| Format-list speed,numberofCores,description,sizeofL3,speedofL3

 }
 processordescription

echo "_____________________________summary of ram installed________________________________"

function Raminfo {
 get-wmiobject -class win32_physicalmemory |
 foreach {
          new-object -TypeName psobject -property @{
                 manufacturer = $_.Manufacturer
                 bank = $_.Banklabel
                 description = $_.Description
                 slot = $_.Devicelocator
                 "size(MB)" = $_.capacity/1mb
          }
          $RAMINSTALLED += $_.capacity/1mb
 }| Format-table manufacturer,bank,description,slot,"size(MB)"
 "Total RAM:${RAMINSTALLED}MB"
 }
 Raminfo

 echo "__________________________summary of the physical disk drives_______________________________--"

 function physicaldisk {
  $diskdrives = Get-CIMInstance CIM_diskdrive

   foreach ($disk in $diskdrives) {
       $partitions = $disk|get-cimassociatedinstance -resultclassname CIM_diskpartition
       foreach ($partition in $partitions) {
             $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
             foreach ($logicaldisk in $logicaldisks) {
                      new-object -typename psobject -property @{Manufacturer=$disk.Manufacturer
                                                                model=$disk.Model
                                                                Drive=$logicaldisk.deviceid
                                                                "Size(GB)"=$logicaldisk.size / 1gb -as [int]
                                                                "spaceusage(GB)"=($logicaldisk.size - $logicaldisk.FreeSpace ) /1gb -as [int]
                                                                } | Format-Table Manufacturer,model,Drive,"Size(GB)","spaceusage(GB)" 
            } 
       }
 } 

}

physicaldisk

echo "______________________________network adapter configuration___________________________________"

function networkadapter {
 Get-CimInstance -className Win32_NetworkAdapterConfiguration | Where-Object IPEnabled -EQ "True" |
     foreach{
                 New-Object -TypeName psobject -Property @{Description =$_.Description
                                                           Index =$_.Index
                                                           IPAddress=$_.ipaddress
                                                           SubnetMask = $_.Ipsubnet
                                                           DNSName=$_.dnsdomain
                                                           DNSServer=$_.DNSServersearchorder
                                                           }
         }|Format-Table Description,Index,IPAddress, Subnetmask,DNSName,DNSServer
}
networkadapter


echo "_________________-___video card vendor, description, and current screen resolution____________________________"

function videocardinfo {
get-wmiobject -class win32_videocontroller |
 foreach {
          new-object -TypeName psobject -property @{
                 manufacturer = $_.AdapterCompatibility
                 description = $_.Description
                 currentscreenpixels = [string]$_.CurrentHorizontalResolution  + "x"  + $_.CurrentVerticalResolution
          }

 }| Format-list manufacturer,description,currentscreenpixels
}

videocardinfo



