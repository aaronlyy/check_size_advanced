# script to check the size of vhdx disks and get the corresponding name
# can be used with single file or complete directory

Param(
    [Parameter(Mandatory, HelpMessage="Path to a directory of multiple vhdx disks or a absolute path to a single disk")]
    [Alias("p")]
    [String]
    $Path = $null,

    [Parameter(Mandatory, HelpMessage="Max disk size in Gb")]
    [Alias("m")]
    [Float]
    $Max,

    [Parameter(HelpMessage="Warning space limit as % (0.5, 0.95, etc.)")]
    [Alias("w")]
    [Float]
    $Warning = 0.95,

    [Parameter(HelpMessage=("Set to true if given path is a single file"))]
    [Alias("s")]
    [Switch]
    $Single
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

$resOk = @{}
$resWarning = @{}
$resCritical = @{}

$warningGb = $Max * $Warning # calculate the warning gb

if ($Single.isPresent){
    # single switch is set, get only one file
    $sizeGb = Get-Size $Path
    $sizeGbRound = [math]::Round($sizeGb,2)
    # check if size -Ne $null to validate success
    if ($sizeGb -Ne $null){
        # check size against limit
        if ($sizeGb -Ge $Max){
            # size is -Ge to Disk, add path and critical to table
            $resCritical[$Path] = $sizeGbRound
        }
        elseif ($sizeGb -Ge $warningGb){
            # limit is greater or equal to limitGb, add path and warning
            $resWarning[$Path] = $sizeGbRound
        }
        else {
            # everytings fine, add path and ok to table
            $resOk[$Path] = $sizeGbRound
        }
    }
    else {
        $resWarning[$Path] = "Error getting file size"
    }
}
else {
    # passed path is a directory
    $files = Get-ChildItem $Path -Filter "*.vhdx" | ForEach { $_.FullName }
    foreach ($f in $files) {
        $sizeGb = Get-Size -f $f
        $sizeGbRound = [math]::Round($sizeGb,2)
        if ($sizeGb -Ne $null){
        # check size against limit
            if ($sizeGb -Ge $Max){
                # size is -Ge to Disk, add path and critical to table
                $resCritical[$f] = $sizeGbRound
            }
            elseif ($sizeGb -Ge $warningGb){
                # limit is greater or equal to limitGb, add path and warning
                $resWarning[$f] = $sizeGbRound
            }
            else {
                # everytings fine, add path and ok to table
                $resOk[$f] = $sizeGbRound
            }
        }
        else {
            $resWarning[$f] = "Error getting file"
        }
    }
}

if ($resWarning.Count -Gt 0 -And $resCritical.Count -Gt 0) {
    $code = 2
    foreach ($f in $resWarning.getEnumerator()){
        $name = $f.Name
        $value = $f.Value 
        Write-Host "Warning: $name - $value/$Max (Gb)"
    }

    foreach ($f in $resCritical.getEnumerator()){
        $name = $f.Name
        $value = $f.Value
        Write-Host "Critical: $name - $value/$Max (Gb)"
    }

}
elseif ($resWarning.Count -Gt 0){
    $code = 1
    foreach ($f in $resWarning.getEnumerator()){
        $name = $f.Name
        $value = $f.Value
        Write-Host "Warning: $name - $value/$Max (Gb)"
    }
}
elseif ($resCritical.Count -Gt 0){
    $code = 2
    foreach ($f in $resCritical.getEnumerator()){
        $name = $f.Name
        $value = $f.Value
        Write-Host "Critical: $name - $value/$Max (Gb)"
    }
}
else {
    $code = 0
    Write-Host "Ok"
}

exit($code)