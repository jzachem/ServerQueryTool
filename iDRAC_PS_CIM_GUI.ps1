

$session = 0
$session


# Quasi Manifest Constants 

$MEDIATYPE_HDD = 0 
$MEDIATYPE_SSD = 1 

$BUSPROTOCOL_SATA = 5 
$BUSPROTOCOL_SAS  = 6
$BUSPROTOCOL_PCIe = 7 

# End Quasi Manifest Constants 

# Show the GUI or just stdout,stderr

$ShowGUI = 1  # 0 = No GUI, 1 = Show GUI 


function CreateCIMSession
{

Write-Output ("Enter Function CreateCIMSession")

$computername="10.208.51.3"
$username="root"
$pwod="calvin"


$password=ConvertTo-SecureString $pwod -AsPlainText  -Force
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password
      
$cimop=New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl 
$script:session=New-CimSession -Authentication Basic -Credential $credentials -ComputerName $computername -Port 443 -SessionOption $cimop -OperationTimeoutSec 10000000 

$script:session

# Start with the SystemView instance
$System = Get-CimInstance -CimSession $script:session -ResourceUri "http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_SystemView"

Write-Output ("Exit Function CreateCIMSession")

}

CreateCIMSession




# Fill up some variables 

$Svctag=$System.ServiceTag
$Model=$System.Model
$bios=$system.BIOSVersionString
#$File = New-Item -ItemType file -Name "$Svctag-$Model.txt" -Force
$ServiceTagString = "Service Tag: $Svctag"

#$Memory=Get-CimInstance -CimSession $session -ResourceUri "http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_MemoryView"
#$CPU=Get-CimInstance -CimSession $session -ResourceUri "http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_CPUView"
<#$NICs = Get-CimInstance  -CimSession $session -ResourceUri "http://schemas.dell.com/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_NICView" 
foreach ($NIC in $NICs) 
{
    $ProdName = $NIC.ProductName
    $ProdName 
}
#>


# The the iDracVeiw instance 
#$iDRAC=Get-CimInstance -CimSession $session -ResourceUri "http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_iDRACCARDView"

# Get the PhysicalDisk instances  
$PhysicalDisks=Get-CimInstance -CimSession $session -ResourceUri "http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_PhysicalDiskView"

# Write the data to the console
# $PhysicalDisks

# Display the number of Physical Drives found in the system 


function DisplayDisks
{
    Write-Output ("Enter Function DisplayDisks") 
    $PhysDisksCount = $PhysicalDisks.Count
    $PhysDisksCount
    Write-Output ("Exit Function DisplayDisks") 
}
 
DisplayDisks 


$PhysDisksDisplayString = ("Physical Disks in System: $PhysDisksCount")

# Variable to hold number of each type of drive

$Num_HDD = 0
$Num_SATA_HDD = 0
$Num_SAS_HDD = 0
$Num_Unknown_HDD = 0

$Num_SSD = 0
$Num_SATA_SSD = 0 
$Num_SAS_SSD = 0 
$Num_PCIe_SSD = 0 # a.k.a NVMe 
$Num_Unknown_SSD = 0 

$Num_Unknown = 0


  

foreach ($Disk in $PhysicalDisks)
{
    #$Disk.MediaType      # Print out for debug 
    #$Disk.BusProtocol    # Pring out for debug 

    if ($Disk.MediaType -eq $MEDIATYPE_SSD) # Is it an HDD or SSD? 
    {
        
        $Num_SSD = $Num_SSD + 1
            
        # Now deterine what type of SSD 

        if ($Disk.BusProtocol -eq $BUSPROTOCOL_SAS)
        {
            $Num_SAS_SSD = $Num_SAS_SSD +1 
        }
        elseif ($Disk.BusProtocol -eq $BUSPROTOCOL_PCIe)
        {
            $Num_PCIe_SSD = $Num_PCIe_SSD +1 
        }
        elseif ($Disk.BusProtocol -eq $BUSPROTOCOL_SATA) 
        {
            $Num_SATA_SSD = $Num_SATA_SSD +1 
        }
        else 
        {
            $Num_Unknown_SSD = $Num_Unknown_SSD + 1 
        }
                         
    }

    # Is it an HDD? 

    elseif ($Disk.MediaType -eq $MEDIATYPE_HDD)
    {
        $Num_HDD = $Num_HDD + 1

        # Is it a SAS drive? 
        if ($Disk.BusProtocol -eq $BUSPROTOCOL_SAS ) 
        { 
             # Yes
             $Num_SAS_HDD = $Num_SAS_HDD +1  
        }

        # Is it a SATA drive? 

        elseif ($Disk.BusProtocol -eq $BUSPROTOCOL_SATA) 
        {
                # Yes 
                $Num_SATA_HDD = $Num_SATA_HDD +1 
        }
        
        # It is an unknown bus protocol 
        
        else 
        {
            $Num_Unknown_SSD = $Num_Unknown_SSD + 1 
        } 


    }

    # Not a known media type 
    
    else 
    {
        $Num_Unknown = $Num_Unknown + 1 
    }
 }

$HDD_Count_String = "Number of HDD: $Num_HDD"
Write-Output $HDD_Count_String
$HDD_SATA_Count_String = "SATA HDD: $Num_SATA_HDD"
Write-Output $HDD_SATA_Count_String
$HDD_SAS_Count_String = "SAS HDD: $Num_SAS_HDD"
Write-Output $HDD_SAS_Count_String

$SSD_Count_String = "Number of SSD: $Num_SSD"
Write-Output $SSD_Count_String
$SSD_SATA_Count_String = "SATA SSD: $Num_SATA_SSD"
Write-Output $SSD_SATA_Count_String
$SSD_SAS_Count_String = "SAS SSD: $Num_SAS_SSD"
Write-Output $SSD_SAS_Count_String
$SSD_PCIe_Count_String = "NVMe SSD: $Num_PCIe_SSD"
Write-Output $SSD_PCIe_Count_String


$Unknown_Count_String = "Number of Unknown Drives: $Num_Unknown"
Write-Output $Unknown_Count_String


#$VirtualDisk=Get-CimInstance -CimSession $session -ResourceUri "http://schemas.dell.com/wbem/wscim/1/cim-schema/2/DCIM_VirtualDiskView"


#$idracinfo=$iDRAC | select Model,FirmwareVersion, PermanentMacAddress | fl | Out-String
#$idracinfo

<# $NIC 
$NICNames = $NICs | select InstanceID, FQDD, DeviceDescription, ProductName, MaxBandWidth | fl | Out-string
$NICNames

# Display the nunber of NICs found in the system. 
$NICs.Count
#>


# Close all open CIM Sesssions 
Get-CimSession | Remove-CimSession 

# Close the open session, should only be one open session 
# Remove-CimSession -InstanceId $session.InstanceId



if ($ShowGUI -eq 1) 
{

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
 

# Define The Title Bar

$Form = New-Object System.Windows.Forms.Form
$Form.Text="Crush PreOS Node Analysis" 
$Form.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
$Form.BackColor="whitesmoke"
$Form.Size = New-Object System.Drawing.Size(1200,700)


# Define the Page Title 

$objLabel0 = New-Object System.Windows.Forms.Label
$objLabel0.Location = New-Object System.Drawing.Size(435,25) 
$objLabel0.Size = New-Object System.Drawing.Size(400,20) 
$objLabel0.Font = New-Object System.Drawing.Font("Verdana",14,[System.Drawing.FontStyle]::Bold)
$objLabel0.Text = "Crush PreOS Node Analysis"
$Form.Controls.Add($objLabel0) 


$objLabel7 = New-Object System.Windows.Forms.Label
$objLabel7.Location = New-Object System.Drawing.Size(190,20) 
$objLabel7.Size = New-Object System.Drawing.Size(50,50) 
$Form.Controls.Add($objLabel7) 




# Node 1
$objLabel_Node1 = New-Object System.Windows.Forms.Label
$objLabel_Node1.Location = New-Object System.Drawing.Size(10,80) 
$objLabel_Node1.Size = New-Object System.Drawing.Size(280,15) 
$objLabel_Node1.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
$objLabel_Node1.Text = "Crush Node 1"
$Form.Controls.Add($objLabel_Node1) 

$TextBox_Node1 = New-Object System.Windows.Forms.TextBox
$TextBox_Node1.Location = New-Object System.Drawing.Size(10,100) 
$TextBox_Node1.Size = New-Object System.Drawing.Size(380,250) 

$TextBox_Node1.MultiLine = $True 
$TextBox_Node1.ScrollBars = "Vertical" 
$Form.Controls.Add($TextBox_Node1) 
$TextBox_Node1.text=($ServiceTagString +"`r`n")
$TextBox_Node1.AppendText($PhysDisksDisplayString + "`r`n")
#$TextBox_Node1.AppendText($HDD_Count_String + "`r`n")
#$TextBox_Node1.AppendText($SSD_Count_String + "`r`n")
#$TextBox_Node1.AppendText($Unknown_Count_String + "`r`n")
$TextBox_Node1.AppendText($HDD_SAS_Count_String + "`r`n")
$TextBox_Node1.AppendText($HDD_SATA_Count_String + "`r`n")
$TextBox_Node1.AppendText($SSD_SAS_Count_String + "`r`n")
$TextBox_Node1.AppendText($SSD_SATA_Count_String + "`r`n")
$TextBox_Node1.AppendText($SSD_PCIe_Count_String + "`r`n") # Displys as "NVMe" to avoid confusion

#$TextBox_Node1.AppendText("Model: " + $Model + "`r`n")
#$TextBox_Node1.AppendText("BIOS Version: "+$bios)
#$TextBox_Node1.AppendText($idracinfo)  
$TextBox_Node1.Font = New-Object System.Drawing.Font("Verdana",8)


# Node 2 
$objLabel1 = New-Object System.Windows.Forms.Label
$objLabel1.Location = New-Object System.Drawing.Size(400,80) 
$objLabel1.Size = New-Object System.Drawing.Size(280,15) 
$objLabel1.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
$objLabel1.Text = "Crush Node 2"
$Form.Controls.Add($objLabel1) 

$outputBox1 = New-Object System.Windows.Forms.TextBox
$outputBox1.Location = New-Object System.Drawing.Size(400,100) 
$outputBox1.Size = New-Object System.Drawing.Size(380,250) 
$outputBox1.MultiLine = $True 
$outputBox1.ScrollBars = "Vertical" 
$Form.Controls.Add($outputBox1) 
$outputBox1.text=($ServiceTagString +"`r`n")
$outputBox1.Font = New-Object System.Drawing.Font("Verdana",8)


# Node 3
$objLabel2 = New-Object System.Windows.Forms.Label
$objLabel2.Location = New-Object System.Drawing.Size(790,80) 
$objLabel2.Size = New-Object System.Drawing.Size(280,15) 
$objLabel2.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
$objLabel2.Text = "Crush Node 3"
$Form.Controls.Add($objLabel2) 

$outputBox2 = New-Object System.Windows.Forms.TextBox
$outputBox2.Location = New-Object System.Drawing.Size(790,100) 
$outputBox2.Size = New-Object System.Drawing.Size(380,250) 
$outputBox2.MultiLine = $True 
$outputBox2.ScrollBars = "Vertical" 
$Form.Controls.Add($outputBox2) 
$outputBox2.text=($ServiceTagString +"`r`n")
$outputBox2.Font = New-Object System.Drawing.Font("Verdana",8)


# Node 4
$objLabel3 = New-Object System.Windows.Forms.Label
$objLabel3.Location = New-Object System.Drawing.Size(10,370) 
$objLabel3.Size = New-Object System.Drawing.Size(280,15) 
$objLabel3.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
$objLabel3.Text = "Crush Node 4"
$Form.Controls.Add($objLabel3) 

$TextBox_Node4 = New-Object System.Windows.Forms.TextBox
$TextBox_Node4.Location = New-Object System.Drawing.Size(10,390) 
$TextBox_Node4.Size = New-Object System.Drawing.Size(380,250) 
$TextBox_Node4.MultiLine = $True 
$TextBox_Node4.ScrollBars = "Vertical" 
$Form.Controls.Add($TextBox_Node4) 
$TextBox_Node4.text=($ServiceTagString +"`r`n")
$TextBox_Node4.Font = New-Object System.Drawing.Font("Verdana",8)


# Node 5 
$objLabel4 = New-Object System.Windows.Forms.Label
$objLabel4.Location = New-Object System.Drawing.Size(400,370) 
$objLabel4.Size = New-Object System.Drawing.Size(280,15) 
$objLabel4.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
$objLabel4.Text = "Crush Node 5"
$Form.Controls.Add($objLabel4) 

$TextBox_Node5 = New-Object System.Windows.Forms.TextBox
$TextBox_Node5.Location = New-Object System.Drawing.Size(400,390) 
$TextBox_Node5.Size = New-Object System.Drawing.Size(380,250) 
$TextBox_Node5.MultiLine = $True 
$TextBox_Node5.ScrollBars = "Vertical" 
$Form.Controls.Add($TextBox_Node5) 
$TextBox_Node5.text=($ServiceTagString +"`r`n")
$TextBox_Node5.Font = New-Object System.Drawing.Font("Verdana",8)


# Node 6
$objLabel5 = New-Object System.Windows.Forms.Label
$objLabel5.Location = New-Object System.Drawing.Size(790,370) 
$objLabel5.Size = New-Object System.Drawing.Size(280,15) 
$objLabel5.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
$objLabel5.Text = "Crush Node 6"
$Form.Controls.Add($objLabel5) 

$TextBox_Node6 = New-Object System.Windows.Forms.TextBox
$TextBox_Node6.Location = New-Object System.Drawing.Size(790,390) 
$TextBox_Node6.Size = New-Object System.Drawing.Size(380,250) 
$TextBox_Node6.MultiLine = $True
$TextBox_Node6.ScrollBars = "Vertical"  
$Form.Controls.Add($TextBox_Node6) 
$TextBox_Node6.text=($ServiceTagString +"`r`n")
$TextBox_Node6.Font = New-Object System.Drawing.Font("Verdana",8)

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()



} # end if show GUI 
 