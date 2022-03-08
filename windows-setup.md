# Windows Setup

## Install OpenSSH
Make sure the OpenSSH client is installed.
```
dism /online /Add-Capability /CapabilityName:OpenSSH.Client
```

## Install and Configure WSL
Launch an elevated powershell window and install WSL2:
```
wsl --install
```
If you see the help text for the wsl command, that means you have WSL already installed and can continue to the next step. Otherwise, this command will download and install the default linux distro (Ubuntu).

Reboot when the install is complete, and launch **Ubuntu** from the start menu to finish the configuration and create a user. Use the same username and password as your Windows install.

In a WSL terminal, create a wsl.conf file and enable file metadata (this makes commands like chmod work).
```
cat <<EOF | sudo tee /etc/wsl.conf
[automount]
options = "metadata"
EOF
```

Open an elevated command prompt and restart WSL:
```
wsl --shutdown
```
Wait [8 seconds](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#the-8-second-rule) for WSL to restart.

## Shared SSH Config
From a WSL terminal, remove any existing Windows ssh config, create a new empty directory, and link it into your WSL home directory:
```
rm -r /mnt/c/Users/<winuser>/.ssh
mkdir -p /mnt/c/Users/<winuser>/.ssh
ln -fs /mnt/c/Users/<winuser>/.ssh ~/.ssh
```

## Terminal
Download the Meslo Nerd monospace fonts, courtesy of [Powerlevel10k](https://github.com/romkatv/powerlevel10k/blob/master/font.md)
* [MesloLGS NF Regular.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
* [MesloLGS NF Bold.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
* [MesloLGS NF Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
* [MesloLGS NF Bold Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)
Open each font file and click Install.

Open **Windows Terminal** from the start menu. Th first time it is launched it should prompt you to set it as the default - do this. 
Wile you are in Setting, go down to Profiles, select Ubuntu and click Appearance. Change the font to MesloLGS NF and set the size to 
what you are comfortable with (I prefer 10). Save the settings and close the settings tab.
