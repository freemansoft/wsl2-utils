# SPDX-FileCopyrightText: 2023 Joe Freeman joe@freemansoft.com
#
# SPDX-License-Identifier: MIT
#

<#
    .Synopsis
    Migrates a WSL storage location to another disk or directory.

    .Description
    Migrates a WSL storage location to another disk or directory. Can also be used for taking backups.

    .Link
    https://github.com/freemansoft/wsl2-utils
#>
param (
    # the originating WSL distribution name
    [String]$WslSourceName = "kali-linux",                       

    # the target locaton for the distribution backup
    [String]$ExportDir = "I:\wsl-export",                       
    # the filename of the backup - default adds timestame to avoid overwrite
    [String]$WslExportName = 
    "$WslSourceName-$(get-date -f yyyyMMdd-HHmmss).tar",    

    # the target location for the new distribution vhdx file
    [String]$DestDir = "I:\wsl",                                 
    # the destination WSL distribution name defaults to src
    [String]$WslDestName = $WslSourceName,                        
    # make this new distribution the default distribution
    [boolean]$WslDestAsDefault = $true,                           

    # execute all steps but just log unregister and import if false
    [boolean]$ExecuteUnregisterImport = $false                  
)
$ExportFullPath = "$ExportDir\$WslExportName"                   # the full path with filename to the distribution backup
$DestFullPath = "$DestDir\$WslSourceName"                       # the full path to the distribution target vhdx filename

# set to one to turn on tracing
Set-PSDebug -Trace 0

# TODO: Add a - are you sure you want to do this with the config info

# --quiet doesn't show the words (default)
$WslList = wsl --list --quiet
if ($WslList.contains($WslSourceName)) {
    Write-Output "wsl distribution $WslSourceName exists"
}
else {
    Write-Output "wsl distribution $WslSourceName does not exist in $WslList"
    return 11
}
Write-Output "Moving instance $WslSourceName to $DestDir"

# TODO: Add verification these commands succeeded
New-Item -ItemType Directory -Force -Path $ExportDir | out-null
if (!(test-path -PathType container $ExportDir)) {
    Write-Output "$ExportDir does not exist and was not created"
    return 12
}
New-Item -ItemType Directory -Force -Path $DestDir | out-null
if (!(test-path -PathType container $DestDir)) {
    Write-Output "$DestDir does not exist and was not created"
    return 13
}

Write-Output "Terminating WSL $WslSourceName"
wsl -t "$WslSourceName"
if ( $?) {
    Write-Output "Export $WslSourceName to file $ExportFullPath"
    wsl --export "$WslSourceName" "$ExportFullPath"
    # check for command success and resulting file.  
    # todo: should check size also
    if (( $? ) -and ( Test-Path -Path "$ExportFullPath" -PathType Leaf )) {
        if ($WslDestName -ne '') {
            # pretend we are unregistering and importing if only testing
            Write-Output "Unregistering existing instance of $WslSourceName"
            if ($ExecuteUnregisterImport) { wsl --unregister "$WslSourceName" } 
            else { Write-Output("    Non destructive mode") }
            Write-Output "Importing $WslDestName to location $DestFullPath from export file $ExportFullPath"
            if ($ExecuteUnregisterImport) { wsl --import "$WslDestName" "$DestFullPath" "$ExportFullPath" } 
            else { Write-Output("    Non destructive mode") }

            switch ($WslDestAsDefault) {
                $true {
                    Write-Output "Setting default wsl distribution to $WslDestName"
                    if ($ExecuteUnregisterImport) { wsl --setdefault "$WslDestName" }  
                    else { Write-Output("    Non destructive mode") }
                }
            }
            # todo: should verify it exists like we did above - remove the --verbose for that
            wsl --list --verbose
            return 0
        }
        else {
            Write-Output "No wsl destination name specified. Treating as backup of $WslSourceName"
            return 21
        }
    }
    else {
        Write-Output "Abort: Failed to backup instance"
        return 22
    }
}
else {
    Write-Output "Abort: Failed to terminate instance"
    return 23
}
# Set-PSDebug -Trace 0
# no return needed here