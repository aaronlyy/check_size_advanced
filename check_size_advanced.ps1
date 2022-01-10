# script to check the size of single files or files in folders

# TODO
# function to get size of file
# function to get size of folder
# function to get size of multiple files
# function to get the username from an sid
# function to calculate kb to mb and kb to gb
# functiont to get the sid out of an vhdx filename
# function to generate full output from an hashtable
# function to get simple output for monitoring systems (status, count, etc)
# function to get 
# main script

Param(
    [Parameter(Mandatory, HelpMessage="Path to a file or a directory")]
    [Alias("p")]
    [String]
    $Path,

    [Parameter(HelpMessage="Check mode. (single, multi, dir), default: single")]
    [Alias("m")]
    [ValidateSet("single", "multi", "folder")]
    [String]
    $Mode,

    [Parameter(HelpMessage="File extension filter")]
    [Alias("f")]
    [String[]]
    $Filter,

    [Parameter(HelpMessage="Enable warning at a specific file/folder size")]
    [Alias("w")]
    [Int]
    $Warning,

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