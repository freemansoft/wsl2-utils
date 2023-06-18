# SPDX-FileCopyrightText: 2023 Joe Freeman joe@freemansoft.com
#
# SPDX-License-Identifier: MIT
#

param (
    [String]$WslName= "kali-linux",             # the WSL distribution name
    [String]$WslExportName= "$WslName.tar",     # the filename of the distribution backup

    [String]$ExportDir=  "I:\wsl-export",       # the target locaton for the distribution backup
    [String]$DestDir= "I:\wsl"                  # the target location for the new distribution vhdx file
)
$ExportFullPath = "$ExportDir\$WslExportName"   # the full path with filename to the distribution backup
$DestFullPath="$DestDir\$WslName"               # the full path to the distribution target vhdx filename

# set to one to turn on tracing
Set-PSDebug -Trace 0

# TODO: Add a - are you sure you want to do this with the config info

Write-Output "Moving instance $WslName to $DestDir"
$WslList = wsl --list
if ($WslList.contains($WslName)){
    Write-Output "wsl distribution $WslName exists"
} else {
    Write-Output "wsl distribution $WslName does not exist in $WslList"
    return
}

# TODO: Add verification these commands succeeded
New-Item -ItemType Directory -Force -Path $ExportDir
New-Item -ItemType Directory -Force -Path $DestDir

Write-Output "Terminating $WslName"
wsl -t "$WslName"
if ( $?){
    Write-Output "Export $WslName to file $ExportFullPath"
    wsl --export "$WslName" "$ExportFullPath"
    # check for command success and resulting file.  
    # todo: should check size also
    if (( $? ) -and ( Test-Path -Path "$ExportFullPath" -PathType Leaf )){
        Write-Output "Unregistering existing instance of $WslName"
        wsl --unregister "$WslName"
        Write-Output "Importing $WslName to location $DestFullPath from export file $ExportFullPath"
        wsl --import "$WslName" "$DestFullPath" "$ExportFullPath"
        # todo: should verify it exists like we did above
        wsl --list
    } else {
        Write-Output "Abort: Failed to backup instance"
    }
} else {
    Write-Output "Abort: Failed to terminate instance"
}
# Set-PSDebug -Trace 0