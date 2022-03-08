# Windows Setup
These instructions are for setting up Windows 11 with WSL, docker and VS Code to do containerized development (mostly python but works with other languages as well).

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

Open an elevated powershell and restart WSL:
```
wsl --shutdown
```
Wait [8 seconds](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#the-8-second-rule) for WSL to restart.

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

## Update Ubuntu
Update Ubuntu to the latest packages:
```
sudo apt-get update
sudo apt-get upgrade -y
```

## Install docker in WSL
Note this is not installing Docker Desktop, this is using the linux version of docker inside WSL.

The official instructions for installing docker on Ubuntu can be used: https://docs.docker.com/engine/install/ubuntu/  
Or follow the summary here.  
If you are going to copy-paste these instructions, execute some other sudo command first to authorize.
```
sudo apt-get update
sudo apt-get install --no-install-recommends -y ca-certificates curl gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
```
To make the docker daemon start on boot, configure /etc/wsl.conf to launch it on startup. You should already have a wsl.conf from the WSL/SSH setup, add a [boot] section to it to launch dockerd:
```
cat <<EOF | sudo tee -a /etc/wsl.conf
[boot]
command = "service docker start"
EOF
```
Now test docker by closing your terminal window and opening a new one, and by rebooting and opening a new WSL terminal. You should be able to run `docker version` and see the client and server versions.

## SSH Configuration
First make sure the OpenSSH client is installed in Windows. From an elevated powershell:
```
dism /online /Add-Capability /CapabilityName:OpenSSH.Client
```
Next we want to make our SSH configuration shared between Windows and WSL. From a WSL terminal, remove any existing Windows ssh config, create a new empty directory, and link it into your WSL home directory:
```
rm -r /mnt/c/Users/<winuser>/.ssh
mkdir -p /mnt/c/Users/<winuser>/.ssh
ln -fs /mnt/c/Users/<winuser>/.ssh ~/.ssh
```
Now we can create an SSH key:
```
ssh-keygen -t ed25519
```
Hit enter at the prompts to accept the defaults.
