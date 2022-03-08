# Windows Local Development

These instructions are for WIndows 11 wunning WSL2. Make sure WSL2 is installed and upgraded before continuing.

## Install docker in WSL
Note this is not installing Docker Desktop, this is using the linux version of docker inside WSL.

The official instructions for isntalling docker on Ubuntu can be used: https://docs.docker.com/engine/install/ubuntu/  
Or follow the summary here.  
If you are going to copy-paste these instructions, execute some other sudo command first to authorize.
```
sudo apt-get update
sudo apt-get install --no-install-recommends -y ca-certificates curl gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
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
