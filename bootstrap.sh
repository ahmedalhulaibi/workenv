#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

UPGRADE_PACKAGES=${1:-none}

if [ "${UPGRADE_PACKAGES}" != "none" ]; then
  echo "==> Updating and upgrading packages ..."

  # Add third party repositories
  sudo add-apt-repository ppa:keithw/mosh-dev -y
  sudo add-apt-repository ppa:jonathonf/vim -y

  CLOUD_SDK_SOURCE="/etc/apt/sources.list.d/google-cloud-sdk.list"
  CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
  if [ ! -f "${CLOUD_SDK_SOURCE}" ]; then
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a ${CLOUD_SDK_SOURCE}
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  fi

  sudo apt-get update
  sudo apt-get upgrade -y
fi

sudo apt-get install -qq \
  apache2-utils \
  apt-transport-https \
  build-essential \
  bzr \
  ca-certificates \
  clang \
  cmake \
  curl \
  direnv \
  dnsutils \
  docker.io \
  fakeroot-ng \
  gdb \
  git \
  git-crypt \
  gnupg \
  gnupg2 \
  google-cloud-sdk \
  google-cloud-sdk-app-engine-go \
  htop \
  hugo \
  ipcalc \
  jq \
  less \
  libclang-dev \
  liblzma-dev \
  libpq-dev \
  libprotoc-dev \
  libsqlite3-dev \
  libssl-dev \
  libvirt-clients \
  libvirt-daemon-system \
  lldb \
  locales \
  man \
  mosh \
  mtr-tiny \
  musl-tools \
  ncdu \
  netcat-openbsd \
  openssh-server \
  pkg-config \
  protobuf-compiler \
  pwgen \
  python \
  python3 \
  python3-flake8 \
  python3-pip \
  python3-setuptools \
  python3-venv \
  python3-wheel \
  qemu-kvm \
  qrencode \
  quilt \
  shellcheck \
  silversearcher-ag \
  socat \
  software-properties-common \
  sqlite3 \
  stow \
  sudo \
  tig \
  tmate \
  tmux \
  tree \
  unzip \
  wget \
  zgen \
  zip \
  zlib1g-dev \
  vim-gtk3 \
  zsh \
  --no-install-recommends \

sudo rm -rf /var/lib/apt/lists/*

# install ripgrep
if ! [ -x "$(command -v rg)" ]; then
  export RIPGREP_VERSION="11.0.2"
  curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep_${RIPGREP_VERSION}_amd64.deb
  sudo dpkg -i ripgrep_${RIPGREP_VERSION}_amd64.deb
  rm -f ripgrep_${RIPGREP_VERSION}_amd64.deb
fi

# install Go
if ! [ -x "$(command -v go)" ]; then
  export GO_VERSION="1.13"
  wget "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" 
  sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" 
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"
  export PATH="/usr/local/go/bin:$PATH"
fi

# install 1password
if ! [ -x "$(command -v op)" ]; then
  export OP_VERSION="v0.9.4"
  curl -sS -o 1password.zip https://cache.agilebits.com/dist/1P/op/pkg/${OP_VERSION}/op_linux_amd64_${OP_VERSION}.zip
  sudo unzip 1password.zip op -d /usr/local/bin
  rm -f 1password.zip
fi

# install terraform
if ! [ -x "$(command -v terraform)" ]; then
  export TERRAFORM_VERSION="0.12.24"
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
  chmod +x terraform
  sudo mv terraform /usr/local/bin
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
fi

# install protobuf
if ! [ -x "$(command -v protoc)" ]; then
  export PROTOBUF_VERSION="3.8.0"
  mkdir -p protobuf_install 
  pushd protobuf_install
  wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
  unzip protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
  sudo mv bin/protoc /usr/local/bin
  sudo mv include/* /usr/local/include/
  popd
  rm -rf protobuf_install
fi

# install tools
if ! [ -x "$(command -v jump)" ]; then
  echo " ==> Installing jump .."
  export JUMP_VERSION="0.30.1"
  wget https://github.com/gsamokovarov/jump/releases/download/v${JUMP_VERSION}/jump_${JUMP_VERSION}_amd64.deb
  sudo dpkg -i jump_${JUMP_VERSION}_amd64.deb
  rm -f jump_${JUMP_VERSION}_amd64.deb
fi

if ! [ -x "$(command -v gh)" ]; then
  echo " ==> Installing gh  .."
  export HUB_VERSION="0.6.4"
  wget https://github.com/cli/cli/releases/download/v${HUB_VERSION}/gh_${HUB_VERSION}_linux_amd64.deb
  sudo dpkg -i gh_${HUB_VERSION}_linux_amd64.deb
  rm -f gh_${HUB_VERSION}_linux_amd64.deb
fi

VIM_PLUG_FILE="${HOME}/.vim/autoload/plug.vim"
if [ ! -f "${VIM_PLUG_FILE}" ]; then
  echo " ==> Installing vim plugins"
  curl -fLo ${VIM_PLUG_FILE} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  mkdir -p "${HOME}/.vim/plugged"
  pushd "${HOME}/.vim/plugged"
  git clone "https://github.com/AndrewRadev/splitjoin.vim"
  git clone "https://github.com/ConradIrwin/vim-bracketed-paste"
  git clone "https://github.com/Raimondi/delimitMate"
  git clone "https://github.com/SirVer/ultisnips"
  git clone "https://github.com/cespare/vim-toml"
  git clone "https://github.com/corylanou/vim-present"
  git clone "https://github.com/ekalinin/Dockerfile.vim"
  git clone "https://github.com/elzr/vim-json"
  git clone "https://github.com/fatih/vim-hclfmt"
  git clone "https://github.com/fatih/vim-nginx"
  git clone "https://github.com/fatih/vim-go"
  git clone "https://github.com/hashivim/vim-hashicorp-tools"
  git clone "https://github.com/junegunn/fzf.vim"
  git clone "https://github.com/mileszs/ack.vim"
  git clone "https://github.com/roxma/vim-tmux-clipboard"
  git clone "https://github.com/plasticboy/vim-markdown"
  git clone "https://github.com/scrooloose/nerdtree"
  git clone "https://github.com/t9md/vim-choosewin"
  git clone "https://github.com/tmux-plugins/vim-tmux"
  git clone "https://github.com/tmux-plugins/vim-tmux-focus-events"
  git clone "https://github.com/fatih/molokai"
  git clone "https://github.com/tpope/vim-commentary"
  git clone "https://github.com/tpope/vim-eunuch"
  git clone "https://github.com/tpope/vim-fugitive"
  git clone "https://github.com/tpope/vim-repeat"
  git clone "https://github.com/tpope/vim-scriptease"
  git clone "https://github.com/ervandew/supertab"
  popd
fi

if [ ! -d "$(go env GOPATH)" ]; then
  echo " ==> Installing Go tools"
  # vim-go tooling
  go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct
  go get -u -v github.com/mdempsky/gocode
  go get -u -v github.com/rogpeppe/godef
  go get -u -v github.com/zmb3/gogetdoc
  go get -u -v golang.org/x/tools/cmd/goimports
  go get -u -v golang.org/x/tools/cmd/gorename
  go get -u -v golang.org/x/tools/cmd/guru
  go get -u -v golang.org/x/tools/gopls
  go get -u -v golang.org/x/lint/golint
  go get -u -v github.com/josharian/impl
  go get -u -v honnef.co/go/tools/cmd/keyify
  go get -u -v github.com/fatih/gomodifytags
  go get -u -v github.com/fatih/motion
  go get -u -v github.com/koron/iferr

  # generic
  go get -u -v github.com/aybabtme/humanlog/cmd/...
  go get -u -v github.com/fatih/hclfmt

  export GIT_TAG="v1.2.0" 
  go get -d -u github.com/golang/protobuf/protoc-gen-go 
  git -C "$(go env GOPATH)"/src/github.com/golang/protobuf checkout $GIT_TAG 
  go install github.com/golang/protobuf/protoc-gen-go

  cp -r $(go env GOPATH)/bin/* /usr/local/bin/
fi

if [ ! -d "${HOME}/.fzf" ]; then
  echo " ==> Installing fzf"
  git clone https://github.com/junegunn/fzf "${HOME}/.fzf"
  pushd "${HOME}/.fzf"
  git remote set-url origin git@github.com:junegunn/fzf.git 
  ${HOME}/.fzf/install --bin --64 --no-bash --no-zsh --no-fish
  popd
fi

if [ ! -d "${HOME}/.zsh" ]; then
  echo " ==> Installing zsh plugins"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.zsh/zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.zsh/zsh-autosuggestions"
fi

if [ ! -d "${HOME}/.tmux/plugins" ]; then
  echo " ==> Installing tmux plugins"
  git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
  git clone https://github.com/tmux-plugins/tmux-open.git "${HOME}/.tmux/plugins/tmux-open"
  git clone https://github.com/tmux-plugins/tmux-yank.git "${HOME}/.tmux/plugins/tmux-yank"
  git clone https://github.com/tmux-plugins/tmux-prefix-highlight.git "${HOME}/.tmux/plugins/tmux-prefix-highlight"
fi

echo "==> Setting shell to zsh..."
chsh -s /usr/bin/zsh

echo "==> Creating dev directories"
mkdir -p ~/code/dotfiles

if [ ! -d ~/code/dotfiles ]; then
  echo "==> Setting up dotfiles"
  # the reason we dont't copy the files individually is, to easily push changes
  # if needed
  cd ~/code
  git clone --recursive https://github.com/ahmedalhulaibi/workenv.git

  cd ~/code/dotfiles
  git remote set-url origin git@github.com:ahmedalhulaibi/workenv.git

  ln -sfn $(pwd)/vimrc "${HOME}/.vimrc"
  ln -sfn $(pwd)/zshrc "${HOME}/.zshrc"
  ln -sfn $(pwd)/zshrc.pre-oh-my-zsh "${HOME}/.zshrc.pre-oh-my-zsh"
  ln -sfn $(pwd)/tmuxconf "${HOME}/.tmux.conf"
  ln -sfn $(pwd)/tigrc "${HOME}/.tigrc"
  #ln -sfn $(pwd)/git-prompt.sh "${HOME}/.git-prompt.sh"
  ln -sfn $(pwd)/gitconfig "${HOME}/.gitconfig"
  #ln -sfn $(pwd)/agignore "${HOME}/.agignore"
  #ln -sfn $(pwd)/sshconfig "${HOME}/.ssh/config"
fi


if [ ! -f "~/secrets/pull-secrets.sh" ]; then
  echo "==> Creating pull-secret.sh script"

cat > pull-secrets.sh <<'EOF'
#!/bin/bash

set -eu

echo "Authenticating with 1Password"
export OP_SESSION_my=$(op signin https://my.1password.com ahmed.alhulaibi41@gmail.com --output=raw)

echo "Pulling secrets"

op get document 'github_rsa' > github_rsa
op get document 'zsh_private' > zsh_private
op get document 'zsh_history' > zsh_history

rm -f ~/.ssh/github_rsa
ln -sfn $(pwd)/github_rsa ~/.ssh/github_rsa
chmod 0600 ~/.ssh/github_rsa

ln -sfn $(pwd)/zsh_private ~/.zsh_private
ln -sfn $(pwd)/zsh_history ~/.zsh_history

echo "Done!"
EOF

  mkdir -p ~/secrets
  chmod +x pull-secrets.sh
  mv pull-secrets.sh ~/secrets
fi


# Set correct timezone
# timedatectl set-timezone Europe/Istanbul

echo ""
echo "==> Done!"
