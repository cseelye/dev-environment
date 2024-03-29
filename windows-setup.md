# Windows Setup
These instructions are for setting up Windows 11 with WSL, docker and VS Code to do containerized development (mostly python but works with other languages as well).

Please note the instructions are specific about what type of terminal to use (powershell vs WSL) so that commands are executed in the correct environment.


## Install and Configure WSL
Launch an elevated powershell window and install WSL2:
```
wsl --install
```
If you see the help text for the wsl command, that means you have WSL already installed and can continue on. Otherwise, this command will download and install the default linux distro (Ubuntu).

Reboot when the install is complete, and launch **Ubuntu** from the start menu to finish the configuration and create a user. Use the same username and password as your Windows install (not required but for your sanity).

Fresh WSL install on latest Win11 should have a /etc/wsl.conf already. In a WSL terminal, edit/create a wsl.conf file, make sure systemd is enabled, and enable file metadata (this makes commands like chmod work).
```
cat <<EOF | sudo tee /etc/wsl.conf
[boot]
systemd=true

[automount]
options = "metadata"
EOF
```

Open an elevated powershell and restart WSL:
```
wsl --shutdown
```
Wait [8 seconds](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#the-8-second-rule) for WSL to restart.

## Font Config (Optional)
Download the Meslo Nerd monospace fonts, courtesy of [Powerlevel10k](https://github.com/romkatv/powerlevel10k/blob/master/font.md)
* [MesloLGS NF Regular.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
* [MesloLGS NF Bold.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
* [MesloLGS NF Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
* [MesloLGS NF Bold Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)
Open each font file and click Install.

Open **Windows Terminal** from the start menu. Th first time it is launched it should prompt you to set it as the default - do this. 
Wile you are in Setting, go down to Profiles, select Ubuntu and click Appearance. Change the font to MesloLGS NF and set the size to 
what you are comfortable with (I prefer 10). Save the settings and close the settings tab.

<img src="images/terminal-font.png" width=400/>

If you are using MobaXTerm, go the Settings menu and select Configuration -> Terminal -> Default terminal font settings and change the font to MesloLGS NF.

<img src="images/moba-font.png" width="400"/>

For other terminals/editors check the linked page for instructions.

## MobaXterm fixes
If you are using MobaXterm with ZSH and OMZ, add these keybindings to your .zshrc:
```
bindkey '^[[H' beginning-of-line # Home
bindkey '^[[F' end-of-line # End
bindkey '^[[2~' overwrite-mode # Insert
bindkey '^[[3~' delete-char # Delete
bindkey '^?' backward-delete-char # Backspace
```
You may only need the home/end keys and not the others.

## Update Ubuntu
Update Ubuntu to the latest packages:
```
sudo apt-get update
sudo apt-get upgrade -y
```

## Install docker in WSL
Note this is not installing Docker Desktop, this is using the linux version of docker inside WSL.

The official instructions for installing docker on Ubuntu can be used: https://docs.docker.com/engine/install/ubuntu/  
Or follow the summary here. If you are going to copy-paste these instructions, execute some other sudo command first to authorize.

In a WSL terminal:
```
sudo apt-get update
sudo apt-get install --no-install-recommends -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker $USER
mkdir -p ~/.docker
cat << EOF > ~/.docker/config.json
{
    "features": {
        "buildkit": true
    }
}
EOF
```
Close all WSL terminals you have open and then open an elevated powershell prompt and restart WSL:
```
wsl --shutdown
```
Wait [8 seconds](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#the-8-second-rule) for WSL to restart, then open a new WSL terminal and run `docker version` to make sure everything is working.

Finally, install the docker Windows credential helper to securely store docker login credentials. In a WSL terminal:
```
ver=$(curl -fsSL -o /dev/null -w "%{url_effective}" https://github.com/docker/docker-credential-helpers/releases/latest | xargs basename)
echo $ver
curl -fL "https://github.com/docker/docker-credential-helpers/releases/download/${ver}/docker-credential-wincred-${ver}.windows-amd64.exe" -o docker-credential-wincred.exe
chmod +x docker-credential-wincred.exe
sudo mv docker-credential-wincred.exe /usr/local/bin/
mkdir -p ~/.docker
cat << EOF > ~/.docker/config.json
{
    "features": {
        "buildkit": true
    }
    "credsStore": "wincred.exe"
}
EOF
```

## GnuPG Agent
After you create or import your gpg keys, install pinentry-tty and set the gpg agent to use it. In a WSL terminal:
```
sudo apt install pinentry-tty
cat > ~/.gnupg/gpg-agent.conf <<EOF
pinentry-program /usr/bin/pinentry-tty
EOF
```

## SSH Configuration
First make sure the OpenSSH client is installed in Windows. From an elevated powershell terminal:
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

Configure SSH by creating `~/.ssh/config`. Here is a starting point with some defaults for all hosts, add your customizations for your particular hosts (see references below for more info):
```
echo <<EOF > ~/.ssh/config
Host *
    AddKeysToAgent yes
    AddressFamily inet
    CheckHostIp no
    ConnectTimeout 20
    ConnectionAttempts 1
    ForwardAgent yes
    GSSAPIAuthentication no
    HashKnownHosts no
    IdentitiesOnly yes
    ServerAliveInterval 10
    ServerAliveCountMax 30
    StrictHostKeyChecking ask
    TCPKeepAlive yes
    User root
    ForwardX11 no
    ForwardX11Trusted no
EOF
```
After creating the config file, make sure the file permissions are correct.
```
chmod 600 ~/.ssh/config
```
### References:
> * SSH client config - https://manpages.ubuntu.com/manpages/focal/en/man5/ssh_config.5.html
> * SSH commandline - https://manpages.ubuntu.com/manpages/focal/en/man1/ssh.1.html
> * SSH daemon config - https://manpages.ubuntu.com/manpages/focal/en/man5/sshd_config.5.html

SSH consumes configuration in this order:
1. Command line
2. User config file (~/.ssh/config)
3. System config file (/etc/ssh/ssh_config)

The FIRST place a config value is found, it will be used (later values do not override earlier values). This means that you can specify options on the commandline to override values in your config file. It also means that your config file should be written with the most specific host matching options at the top, to the least specific on the bottom.

## SSH Agent
Adding your SSH key to an agent will automatically make it available to ssh, and allow it to be forwarded so you can use it for multiple ssh hops.

Here is a snippet for .bashrc that you can use to automatically initialize your agent with a list of keys (also make sure ssh-agent is in your list of plugins):
```
ssh_keys=( id_ed25519 github_rsa )
if which ssh-agent &>/dev/null; then
    [[ -z "$SSH_AUTH_SOCK" ]] && eval $(ssh-agent -s) &>/dev/null
    ssh-add -D &>/dev/null
    for f in "${ssh_keys[@]}"; do
        if [[ -e "$HOME/.ssh/$f" ]]; then
            DISPLAY= SSH_ASKPASS= ssh-add "$HOME/.ssh/$f" < /dev/null &>/dev/null
        fi
    done
fi
```

Here is a similar snippet for .zshrc using zsh/omz:
```
ssh_keys=( id_ed25519 github_rsa )
add_keys=()
for kf in "${ssh_keys[@]}"; do
    [[ -e ~/.ssh/${kf} ]] && add_keys+=(${kf})
done
zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent agent-forwarding yes
if [[ -n ${add_keys} ]]; then
    zstyle :omz:plugins:ssh-agent identities ${add_keys}
fi
```


## SSH Without Password
If you want to configure some servers to be able to SSH without typing a password, for instance to enable remote development with VS Code, you need to copy your SSH key into the `authorized_keys` file on the server. The ssh-copy-id command does this for you:
```
ssh-copy-id -i ~/.ssh/id_ed25519.pub username@server_ip
```
The command will prompt you for the password for the user to connect and install the key. After the command completes successfully, the key is installed and you can now connect to the server with ssh username@server_ip and you will connect without being prompted for a password.

After adding your key to the server, you may wish to apply specific config options for it in your ssh config file:
```
Host <simple name>
    HostName <server_ip>
    User <username>
    IdentityFile ~/.ssh/id_ed25519
```
Add any SSH configuration options you want for this specific host. Make sure to add this host block above the `Host *` block.

You can set `<simple name>` to any string you want, it does not need to be the actual hostname. This allows you to ssh to that server using that name, eg if you set `<simple name>` to `myserver`, you can then `ssh myserver` and it will use the IP address you set in the config file to connect.


## VS Code Setup
From a powershell terminal in Windows, install Code and the Remote Development extension pack:
```
winget install Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!desktopicon,!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
```
After the remote dev pack is installed, you should be able to launch code directly from WSL. From any WSL terminal, run `code .` and VS Code should launch and open the current directory.

From a WSL terminal, install the docker extension:
```
code --install-extension ms-azuretools.vscode-docker
```
This must be done from inside WSL so that the extension is installed in the WSL environment where docker is installed.

## WSL Connection with VS Code
There are two ways to develop using code in WSL.

First (and easiest), from a WSL terminal, type `code .` and VS Code will open to the current folder through WSL and you can start work just like a native Windows folder.

Second, open VS Code in Windows, open the Remote Explorer view and select WSL Targets. This will show each of the WSL distros you have installed.

<img src="images/wsl-explorer.png" width=400/>

Right click the Ubuntu distro and click **Connect to WSL**. This will open a new window that is connected to the WSL install. From there you can open a folder and start work just like any folder, but you are working within the WSL system.
