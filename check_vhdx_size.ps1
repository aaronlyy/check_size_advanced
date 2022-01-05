# script to check the size of vhdx disks and get the corresponding name
# can be used with single file or complete directory


Param(
    [Parameter(HelpMessage="Absolute path to a single vhdx disk")]
    [Alias("f")]
    [String]
    $File = $null,

    [Parameter(HelpMessage="Path to a directory of multiple vhdx disks")]
    [Alias("d")]
    [String]
    $Directory = $null,

    [Parameter(HelpMessage="Max disk size in Gb")]
    [Alias("m")]
    [Int]
    $Max,

    [Parameter(Mandatory, HelpMessage="Warning space limit as % (0.5, 0.95, etc.)")]
    [Alias("w")]
    [Float]
    $Warning = 0.95
)

function Get-Size {
    # Get the size of an vdhx disk
    Param(
        [Parameter(Mandatory, HelpMessage="Path to a single vhdx disk")]
        [Alias("f")]
        [String]
        $File
    )

    # Check if given disk exists
    if (Test-Path $File -PathType leaf){
        # Disk exists, get size from disk
        $item = Get-Item $File
        $sizeInB = $item.length
        $sizeInKb = $sizeInB / 1KB
        $sizeInGb = $sizeInB / 1GB
        return $sizeInGb
    }
    else {
        return $null
    }
}


$results = @{}
$code = 0
$warningGb = $Max * $Warning

Write-Host $File

if ($File -Ne $null -And $File -Ne ""){
    # passed parameter is a single file
    # get file size in gb
    $sizeGb = Get-Size $File
    Write-Host $sizeGb
    # check if size -Ne $null to validate success
    if ($sizeGb -Ne $null){
        # check size against limit
        if ($sizGb -Ge $WarningGb){
            # limit is greater or equal to limitGb, add path and warning
            $results[$File] = "$Warning usage exceeded! ($sizeGb)"
        }
        elseif ($sizeGb -Ge $Max){
            # size is -Ge to Disk, add path and critical to table
            $results[$File] = "100% usage! ($sizeGb)"
        }
        else {
            # everytings fine, add path and ok to table
            $results[$File] = "Ok ($size)"
        }
    }
    else {
        $code = -1
        $results[$File] = "Error getting file"
    }
}
elseif ($Directory -Ne $null -And $Directory -Ne ""){
    # passed parameter is directory
    # loop through directory
    continue
}
else {
    Write-Host "Missing Parameter file or directory path!"
    Write-Host "Usage: .\check_vhdx -File f.vhdx -Disk 20 -Warning 0.95"
    $code = -1
}

Write-Host $results[$File]
return $code