
write-host "* * * Installing WSL"
wsl --install  --no-launch

bash -c 'echo "* * * Updating Ubuntu"
sudo ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime
sudo apt-get update
sudo apt-get upgrade -y
'
bach -c 'echo "* * * Installing docker"
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
'

bash -c 'echo "* * * Configuring GPG agent
sudo apt install gpg pinentry-tty
cat > ~/.gnupg/gpg-agent.conf <<EOF
pinentry-program /usr/bin/pinentry-tty
EOF
'

bash -c 'echo "* * * Configuring WSL"
cat <<EOF | sudo tee /etc/wsl.conf
[boot]
systemd=true

[automount]
options = "metadata"
EOF
'

write-host "* * * Restarting WSL"
Get-Service LxssManager | Restart-Service

write-host "* * * Installing VS Code"
winget install Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!desktopicon,!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
code --install-extension cseelye.vscode-allofthem
code --install-extension eriklynd.json-tools
code --install-extension ms-vscode.powershell
code --install-extension streetsidesoftware.code-spell-checker

wsl code --install-extension ms-azuretools.vscode-docker
wsl code --install-extension streetsidesoftware.code-spell-checker
wsl code --install-extension cseelye.vscode-allofthem
wsl code --install-extension eriklynd.json-tools
