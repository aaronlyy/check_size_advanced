# script to check the size of single files or files in folders

# TODO
#* function to get size of file
# function to get size of folder
#* function to get size of multiple files

# function to get the username from an sid
# functiont to get the sid out of an vhdx filename

# --- PARAMETER ---
Param(
    [Parameter(Mandatory, HelpMessage="Path to a file or a directory")]
    [Alias("p")]
    [String]
    $Path,

    [Parameter(HelpMessage="Check mode. (single, multi, dir), default: single")]
    [Alias("m")]
    [ValidateSet("file", "folder", "absfolder")]
    [String]
    $Mode = "file",

    [Parameter(HelpMessage="File extension filter. Use with -m 'multi' to check only specific types of files.")]
    [Alias("f")]
    [String]
    $Filter = "*.*",

    [Parameter(HelpMessage="Set warning at a specific file/folder size (in %, default: 0.95)")]
    [Alias("w")]
    [Float]
    $WarningPercentage = 0.95,

    [Parameter(Mandatory, HelpMessage="Set critical at a specific file/folder size")]
    [Alias("c")]
    [Float]
    $CriticalSize,

    [Parameter(HelpMessage="Size mode (kb, mb, gb), Default: GB")]
    [Alias("b")]
    [ValidateSet("kb", "mb", "gb")]
    [String]
    $Bytes = "gb",

    [Parameter(HelpMessage="VHDX Mode, shows username from given sid")]
    [Alias("v")]
    [Switch]
    $Vhdx
)

#* ------ FUNCTIONS ------
function Get-Size {
    # returns file size, return $null if path is not a file
    Param(
        [Parameter(Mandatory, HelpMessage="Path to a single file")]
        [Alias("f")]
        [String]
        $File,

        [Parameter(HelpMessage="Size mode (kb, mb, gb), Default: GB")]
        [ValidateSet("kb", "mb", "gb")]
        [Alias("b")]
        [String]
        $Bytes = "gb"
    )

    # Check if given path is a file and exists
    if (Test-Path $File -PathType leaf){
        $item = Get-Item $File
        $sizeInB = $item.length
        # return size
        if ($Bytes -Eq "kb"){
            return $sizeInB / 1KB
        }
        elseif ($Bytes -Eq "mb"){
            return $sizeInB / 1MB
        }
        elseif ($Bytes -Eq "gb"){
            return $sizeInB / 1GB
        }
    }
    else {
        return $null
    }
}

function Get-DirectorySize {
    # returns size of a folder
    Param(
        [Parameter(Mandatory, HelpMessage="Path to a directory")]
        [Alias("d")]
        [String]
        $Directory,

        [Parameter(HelpMessage="Size mode (kb, mb, gb), Default: GB")]
        [ValidateSet("kb", "mb", "gb")]
        [Alias("b")]
        [String]
        $Bytes = "gb"
    )

    # needs to be implemented

}

function Get-MultipleSize {
    # returns a hashtable with abspath: size
    Param(
    [Parameter(Mandatory, HelpMessage="Array of filepaths")]
    [Alias("p")]
    [String[]]
    $Paths,

    [Parameter(HelpMessage="Size mode (kb, mb, gb), Default: GB")]
    [ValidateSet("kb", "mb", "gb")]
    [Alias("b")]
    [String]
    $Bytes = "gb"
    )

    $sizes = @{};
    foreach ($p in $Paths){
        $size = Get-Size -File $p -Bytes $Bytes
        if ($size -Ne $null){
            $sizes.Add($p, $size)
        }
    }

    if ($sizes.Count -Ge 1){
        return $sizes
    }
    else {
        return $null
    }
}

#* ------ MAIN ------
# return codes
$codeOk = 0
$codeWarning = 1
$codeCritical = 2
$codeUnknown = 3

# warning size
$warningSize = $CriticalSize * $WarningPercentage

# hashtables for results
$resOk = @{}
$resWarn = @{}
$resCrit = @{}
$resUnk = @{}

# modes
if ($Mode -Eq "file"){
    # get size of single file in given size mode
    if (Test-Path $Path -PathType leaf){
        $size = Get-Size -File $Path -Bytes $Bytes
        if ($size -Ne $null){
            if ($size -Ge $CriticalSize){
                    $resCrit.Add($Path, $size)
            }
            elseif ($size -Ge $warningSize){
                $resWarn.Add($Path, $size)
            }
            else {
                $resOk.Add($Path, $size)
            }
        }
        else {
            $resUnk.Add($Path, $size)
        }
    }
    else {
        $resUnk.Add($Path, "Mode is file but given path is a folder!")
    }
}
elseif ($Mode -Eq "folder"){
    if (Test-Path $Path -PathType Container){
        $paths = Get-ChildItem $Path -Filter $Filter | ForEach { $_.FullName } # get all files of path
        foreach ($p in $paths){
            $size = Get-Size -File $p -Bytes $Bytes
            if ($size -Ne $null){
                if ($size -Ge $CriticalSize){
                    $resCrit.Add($p, $size)
                }
                elseif ($size -Ge $warningSize){
                    $resWarn.Add($p, $size)
                }
                else {
                    $resOk.Add($p, $size)
                }
            }
            else {
                $resUnk.Add($p, $size)
            }
        }
    }
    else {
        $resUnk.Add($Path, "Mode is folder but given path is a file!")
    }
}
else {
    #! check absolute directory size
}

# set exit code
if ($resCrit.Count -Gt 0){
    $code = $codeCritical
}
elseif ($resWarn.Count -Gt 0){
    $code = $codeWarning
}
elseif ($resUnk.Count -Gt 0){
    $code = $codeUnknown
}
else {
    $code = $codeOk
}

# build output
$output = "Critical: {0}`n" -f $resCrit.Count
$output += "Warning: {0}`n" -f $resWarn.Count
$output += "Unknown: {0}`n" -f $resUnk.Count
$output += "Ok: {0}`n" -f $resOk.Count

if ($resCrit.Count -Gt 0){
    foreach ($r in $resCrit.getEnumerator()){
        $output += "[Critical] {0}: {1}`n" -f $r.Name, $r.Value
    }
}
if ($resWarn.Count -Gt 0){
    foreach ($r in $resWarn.getEnumerator()){
        $output += "[Warning] {0}: {1}`n" -f $r.Name, $r.Value
    }
}
if ($resUnk.Count -Gt 0){
    foreach ($r in $resUnk.getEnumerator()){
        $output += "[Unknown] {0}: {1}`n" -f $r.Name, $r.Value
    }
}

Write-Host $output

exit($code)