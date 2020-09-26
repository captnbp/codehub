#!/bin/bash
cd /tmp
DEBIAN_FRONTEND=noninteractive
CURL_OPTS=""

echo "Install tools"
apt-get update >/dev/null
apt-get dist-upgrade -y
apt-get install --no-install-recommends -y vim pwgen jq wget unzip pass zsh fonts-powerline \
    htop software-properties-common gpg netcat uuid-runtime dnsutils

echo "Install Oh My Zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv /root/.oh-my-zsh /usr/share/oh-my-zsh

echo "Install Vault"
latest_release_url="https://github.com/hashicorp/vault/releases"
TAG=$(curl -Ls $latest_release_url | grep 'href="/hashicorp/vault/releases/tag/v.' | grep -v no-underline | grep -v rc | head -n 1 | cut -d '"' -f 2 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}' | cut -d 'v' -f2)
curl ${CURL_OPTS} -L "https://releases.hashicorp.com/vault/${TAG}/vault_${TAG}_linux_amd64.zip" \
    -o /tmp/vault.zip >/dev/null
unzip /tmp/vault.zip -d /tmp/ >/dev/null
mv -f /tmp/vault /usr/local/bin/vault
chown 755 /usr/local/bin/vault
rm /tmp/vault.zip
vault -autocomplete-install

echo "Install Minio mc client"
curl ${CURL_OPTS} -L "https://dl.min.io/client/mc/release/linux-amd64/mc" \
    -o /usr/local/bin/mc >/dev/null
chmod 755 /usr/local/bin/mc

echo "Set shell to zsh"
chsh -s /usr/bin/zsh
chsh -s /usr/bin/zsh coder

echo "mkdir -p \$HOME/.oh-my-zsh/cache" >> /etc/zsh/zshrc
echo "export ZSH_CACHE_DIR=\$HOME/.oh-my-zsh/cache" >> /etc/zsh/zshrc
echo "plugins=(git docker ansible helm kubectl terraform)" >> /etc/zsh/zshrc
echo "ZSH_THEME=robbyrussell" >> /etc/zsh/zshrc
echo "export ZSH=/usr/share/oh-my-zsh" >> /etc/zsh/zshrc
echo "source \$ZSH/oh-my-zsh.sh" >> /etc/zsh/zshrc
echo "autoload -U +X bashcompinit && bashcompinit" >> /etc/zsh/zshrc
echo "complete -o nospace -C /usr/local/bin/vault vault" >> /etc/zsh/zshrc

echo "Install Ansible and ansible-modules-hashivault"
apt-get install -y --no-install-recommends python3-pip python3-setuptools twine
pip3 install --no-cache-dir hvac elasticsearch virtualenv twine

echo "Cleaning"
rm -rf /var/lib/apt/lists/* /tmp/*