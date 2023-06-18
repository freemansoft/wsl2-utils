# DISCLAIMER
Code in this repository is without Warranty.

**DANGER**
The move script will terminate and unregister your existing WSL instances.  This is a destructive operation that could leave you with no WSL instance if the backup failed. The script attempts to catch this but there may be situations where backupfailure is not detected

# Purpose
The script in this directory will move a WSL instance from one location to a new one using the `wsl export` function.

# Move the linux distribution
Edit this section of move-distribution.ps1` and change the parameters to fit your needs.

```dotnetcli
param (
    [String]$WslName= "kali-linux",
    [String]$WslExportName= "$WslName.tar",

    [String]$ExportDir=  "I:\wsl-export",
    [String]$DestDir= "I:\wsl"
)
```

# Resetting the default user
The import operation will lose the default user resulting in all shells opening as root. 

### Simple fix
Edit the file `/etc/wsl.conf` in each imported system
```
[user]
default=<your_username>
```
Terminate the wsl distribution with `wsl --terminate <distribution-name>` and then open a new terminal into that distribution.

### Explanation
The default UID is `0` which you can see with the output of 
```
Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss\
```
* Ref: https://askubuntu.com/questions/1427355/why-has-my-ubuntu-started-defaulting-to-root-user-on-startup-duel-running-wind

You cannot run `<instance>.exe config --default-user <username>` because the .exe link isn't made with an import


# Todo Items
1. Add a test parameter that doesn't execute the destructive commands
1. Add a backup _only_ script for snapshoting wsl instances
1. Add wsl edit to `/etc/wsl.conf` to update the default user from `0` to something else

# Adding GUI to Distributions

## Kali Linux Hints with WSLg

Install and execute as you
```bash
# install kex
sudo apt update
sudo apt upgrade
sudo apt install -y kali-win-kex
# Jack up the install to everything
sudo apt install -y kali-linux-large
# Start it up
kex --win -s
```

Execute as you from Windows
```dotnetcli
wsl -d kali-linux kex --win -s
```

* Ref: https://www.kali.org/docs/wsl/win-kex/

# Ubuntu
_Just use Kali if you want a linux desktop_ 

Install and execute as you
```bash
# install kex
sudo apt-get update
sudo apt-get upgrade
# ????
# sudo apt install -y ??
# Start it up
# ????
```

* Ref: https://github.com/microsoft/wslg
* Ref: I agree with https://ubunlog.com/en/como-instalar-ubuntu-con-interfaz-grafica-en-windows-gracias-a-wsl2-o-mejor-aun-kali-linux/
