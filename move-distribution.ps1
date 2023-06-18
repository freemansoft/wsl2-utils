# SPDX-FileCopyrightText: 2023 Joe Freeman joe@freemansoft.com
#
# SPDX-License-Identifier: MIT
#

param (
    [String]$WslSourceName= "Ubuntu-20.04",                       # the originating WSL distribution name

    [String]$ExportDir=  "I:\wsl-export",                       # the target locaton for the distribution backup
    [String]$WslExportName= 
        "$WslSourceName-$(get-date -f yyyyMMdd-HHmmss).tar",    # the filename of the backup - no overwrite

    [String]$DestDir= "I:\wsl",                                 # the target location for the new distribution vhdx file
    [String]$WslDestName=$WslSourceName,                        # the destination WSL distribution name defaults to src
    [boolean]$WslDestAsDefault=$true,                           # make this new distribution the default distribution

    [boolean]$ExecuteUnregisterImport=$true                    # execute all steps but just log unregister and import if false
)
$ExportFullPath = "$ExportDir\$WslExportName"                   # the full path with filename to the distribution backup
$DestFullPath="$DestDir\$WslSourceName"                         # the full path to the distribution target vhdx filename

# set to one to turn on tracing
Set-PSDebug -Trace 0

# TODO: Add a - are you sure you want to do this with the config info

# --quiet doesn't show the words (default)
$WslList = wsl --list --quiet
if ($WslList.contains($WslSourceName)){
    Write-Output "wsl distribution $WslSourceName exists"
} else {
    Write-Output "wsl distribution $WslSourceName does not exist in $WslList"
    return
}
Write-Output "Moving instance $WslSourceName to $DestDir"

# TODO: Add verification these commands succeeded
New-Item -ItemType Directory -Force -Path $ExportDir | out-null
if (!(test-path -PathType container $ExportDir)){
    Write-Output "$ExportDir does not exist and was not created"
    return
}
New-Item -ItemType Directory -Force -Path $DestDir | out-null
if (!(test-path -PathType container $DestDir)){
    Write-Output "$DestDir does not exist and was not created"
    return
}

Write-Output "Terminating WSL $WslSourceName"
wsl -t "$WslSourceName"
if ( $?){
    Write-Output "Export $WslSourceName to file $ExportFullPath"
    wsl --export "$WslSourceName" "$ExportFullPath"
    # check for command success and resulting file.  
    # todo: should check size also
    if (( $? ) -and ( Test-Path -Path "$ExportFullPath" -PathType Leaf )){
        if ($WslDestName -ne ''){
            # pretend we are unregistering and importing if only testing
            Write-Output "Unregistering existing instance of $WslSourceName"
            if ($ExecuteUnregisterImport) {wsl --unregister "$WslSourceName"} 
            else { Write-Output("    Non destructive mode")}
            Write-Output "Importing $WslDestName to location $DestFullPath from export file $ExportFullPath"
            if ($ExecuteUnregisterImport) {wsl --import "$WslDestName" "$DestFullPath" "$ExportFullPath"} 
            else { Write-Output("    Non destructive mode")}

            switch ($WslDestAsDefault){
                $true {
                    Write-Output "Setting default wsl distribution to $WslDestName"
                    if ($ExecuteUnregisterImport) {wsl --setdefault "$WslDestName" }  
                    else { Write-Output("    Non destructive mode")}
                }
            }
            # todo: should verify it exists like we did above - remove the --verbose for that
            wsl --list --verbose
        } else {
            Write-Output "No wsl destination name specified. Treating as backup of $WslSourceName"
        }
    } else {
        Write-Output "Abort: Failed to backup instance"
    }
} else {
    Write-Output "Abort: Failed to terminate instance"
}
# Set-PSDebug -Trace 0