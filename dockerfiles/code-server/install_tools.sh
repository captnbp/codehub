#!/bin/bash
set -euo pipefail
cd /tmp
DEBIAN_FRONTEND=noninteractive
CURL_OPTS=""

echo "Install tools"
apt-get update >/dev/null
apt-get dist-upgrade -y
apt-get install --no-install-recommends -y vim pwgen jq wget unzip pass zsh fonts-powerline \
    htop software-properties-common gpg netcat uuid-runtime dnsutils exa skopeo

echo "Install Oh My Zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv /root/.oh-my-zsh /usr/share/oh-my-zsh

echo "Install kubectl"
curl ${CURL_OPTS} -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl >/dev/null
chmod +x /usr/local/bin/kubectl

echo "Install helm"
latest_release_url="https://github.com/helm/helm/releases"
TAG=$(curl -Ls $latest_release_url | grep 'href="/helm/helm/releases/tag/v3.' | grep -v beta | head -n 1 | cut -d '"' -f 6 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}')
curl ${CURL_OPTS} -L "https://get.helm.sh/helm-$TAG-linux-amd64.tar.gz" \
    -o /tmp/helm.tar.gz >/dev/null
tar zxf /tmp/helm.tar.gz -C /tmp/ >/dev/null
mv -f /tmp/linux-amd64/helm /usr/local/bin/helm
chown 755 /usr/local/bin/helm
rm /tmp/helm.tar.gz
rm -Rf /tmp/linux-amd64/

echo "Install Packer"
latest_release_url="https://github.com/hashicorp/packer/releases"
TAG=$(curl -Ls $latest_release_url | grep 'href="/hashicorp/packer/releases/tag/v.' | grep -v beta | grep -v rc | head -n 1 | cut -d '"' -f 6 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}' | cut -d 'v' -f2)
curl ${CURL_OPTS} -L "https://releases.hashicorp.com/packer/${TAG}/packer_${TAG}_linux_amd64.zip" \
    -o /tmp/packer.zip >/dev/null
unzip /tmp/packer.zip -d /tmp/ >/dev/null
mv -f /tmp/packer /usr/local/bin/packer
rm /tmp/packer.zip
packer -autocomplete-install

echo "Install Terraform"
latest_release_url="https://github.com/hashicorp/terraform/releases"
TAG=$(curl -Ls $latest_release_url | grep 'href="/hashicorp/terraform/releases/tag/v.' | grep -v beta | grep -v rc | head -n 1 | cut -d '"' -f 6 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}' | cut -d 'v' -f2)
curl ${CURL_OPTS} -L "https://releases.hashicorp.com/terraform/${TAG}/terraform_${TAG}_linux_amd64.zip" \
    -o /tmp/terraform.zip >/dev/null
unzip /tmp/terraform.zip -d /tmp/ >/dev/null
mv -f /tmp/terraform /usr/local/bin/terraform
chown 755 /usr/local/bin/terraform
rm /tmp/terraform.zip
terraform -install-autocomplete

echo "Install Vault"
latest_release_url="https://github.com/hashicorp/vault/releases"
TAG=$(curl -Ls $latest_release_url | grep 'href="/hashicorp/vault/releases/tag/v.' | grep -v beta | grep -v rc | head -n 1 | cut -d '"' -f 6 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}' | cut -d 'v' -f2)
curl ${CURL_OPTS} -L "https://releases.hashicorp.com/vault/${TAG}/vault_${TAG}_linux_amd64.zip" \
    -o /tmp/vault.zip >/dev/null
unzip /tmp/vault.zip -d /tmp/ >/dev/null
mv -f /tmp/vault /usr/local/bin/vault
chown 755 /usr/local/bin/vault
rm /tmp/vault.zip
vault -autocomplete-install

echo "Install k9s"
latest_release_url="https://github.com/derailed/k9s/releases"
TAG=$(curl -Ls $latest_release_url | grep 'href="/derailed/k9s/releases/tag/v' | grep -v beta  | grep -v rc | head -n 1 | cut -d '"' -f 6 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}')
curl ${CURL_OPTS} -L "https://github.com/derailed/k9s/releases/download/${TAG}/k9s_Linux_x86_64.tar.gz" \
    -o /tmp/k9s.tar.gz >/dev/null
tar zxf /tmp/k9s.tar.gz -C /tmp/ >/dev/null
mv -f /tmp/k9s /usr/local/bin/k9s
chown 755 /usr/local/bin/k9s
rm /tmp/k9s.tar.gz

echo "Install popeye"
latest_release_url="https://github.com/derailed/popeye/releases"
TAG=$(curl -Ls $latest_release_url | grep 'href="/derailed/popeye/releases/tag/v' | grep -v beta  | grep -v rc | head -n 1 | cut -d '"' -f 6 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}')
curl ${CURL_OPTS} -L "https://github.com/derailed/popeye/releases/download/${TAG}/popeye_Linux_x86_64.tar.gz" \
    -o /tmp/popeye.tar.gz >/dev/null
tar zxf /tmp/popeye.tar.gz -C /tmp/ >/dev/null
mv -f /tmp/popeye /usr/local/bin/popeye
chown 755 /usr/local/bin/popeye
rm /tmp/popeye.tar.gz

echo "Install havener"
latest_release_url="https://github.com/homeport/havener/releases"
TAG=$(curl -Ls $latest_release_url | grep 'href="/homeport/havener/releases/tag/v' | grep -v beta  | grep -v rc | head -n 1 | cut -d '"' -f 6 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}' | cut -d 'v' -f2)
curl ${CURL_OPTS} -L "https://github.com/homeport/havener/releases/download/v${TAG}/havener_${TAG}_linux_amd64.tar.gz" \
    -o /tmp/havener.tar.gz >/dev/null
tar zxf /tmp/havener.tar.gz -C /tmp/ >/dev/null
mv -f /tmp/havener /usr/local/bin/havener
chown 755 /usr/local/bin/havener
rm /tmp/havener.tar.gz

echo "Install Scaleway scw cli"
latest_release_url="https://github.com/scaleway/scaleway-cli/releases/"
TAG=$(curl -Ls $latest_release_url | grep 'href="/scaleway/scaleway-cli/releases/tag/v.' | grep -v beta | grep -v rc | head -n 1 | cut -d '"' -f 6 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}' | cut -d 'v' -f2)
wget "https://github.com/scaleway/scaleway-cli/releases/download/v${TAG}/scw-${TAG}-linux-x86_64" -O /usr/local/bin/scw >/dev/null
chmod 755 /usr/local/bin/scw

echo "Install Minio mc client"
curl ${CURL_OPTS} -L "https://dl.min.io/client/mc/release/linux-amd64/mc" \
    -o /usr/local/bin/mc >/dev/null
chmod 755 /usr/local/bin/mc

echo "Install Hadolint"
latest_release_url="https://github.com/hadolint/hadolint/releases"
TAG=$(curl -Ls $latest_release_url | grep 'href="/hadolint/hadolint/releases/tag/v.' | grep -v beta | grep -v rc | head -n 1 | cut -d '"' -f 6 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}')
curl ${CURL_OPTS} -L "https://github.com/hadolint/hadolint/releases/download/${TAG}/hadolint-Linux-x86_64" \
    -o /usr/local/bin/hadolint >/dev/null
chmod 755 /usr/local/bin/hadolint

echo "Install bat"
latest_release_url="https://github.com/sharkdp/bat/releases"
TAG=$(curl -Ls $latest_release_url | grep 'href="/sharkdp/bat/releases/tag/v.' | grep -v beta | grep -v rc | head -n 1 | cut -d '"' -f 6 | awk '{n=split($NF,a,"/");print a[n]}' | awk 'a !~ $0{print}; {a=$0}' | cut -d 'v' -f2)
curl ${CURL_OPTS} -L "https://github.com/sharkdp/bat/releases/download/v${TAG}/bat_${TAG}_amd64.deb" \
    -o /tmp/bat.deb >/dev/null
dpkg -i /tmp/bat.deb
rm /tmp/bat.deb

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
echo "complete -o nospace -C /usr/local/bin/packer packer" >> /etc/zsh/zshrc
echo "complete -o nospace -C /usr/local/bin/terraform terraform" >> /etc/zsh/zshrc
echo "complete -o nospace -C /usr/local/bin/vault vault" >> /etc/zsh/zshrc

echo "Install Ansible and ansible-modules-hashivault"
apt-get install -y --no-install-recommends python3-pip python3-setuptools python3-ldap python3-docker twine python3-psycopg2 postgresql-client
pip3 install --no-cache-dir --upgrade pip
pip3 install --no-cache-dir ansible ansible-modules-hashivault openshift passlib hvac elasticsearch virtualenv twine

echo "Cleaning"
rm -rf /var/lib/apt/lists/* /tmp/*