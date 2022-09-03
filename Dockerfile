FROM amazonlinux:2

# version
ARG RUBY_VERSION=3.1.2
# 3.10 requires openssl 1.1.1
# TODO, figure out how to install from source
ARG PYTHON_VERSION=3.9.13
ARG NEOVIM_VERSION=0.7.2
ARG NODE_VERSION=16.17.0
ARG NVM_VERSION=v0.39.1

# directories
ARG HOME_DIR=/home/unicorn
ARG APPS_DIR=$HOME_DIR/apps
ARG NVM_DIR=$HOME_DIR/.nvm
ARG RVM_DIR=$HOME_DIR/.rvm

# update all the packages
RUN yum update -y

RUN yum install -y \
  git \
  which \
  wget \
  tar \
  procps


# run container under a user
RUN adduser unicorn 


RUN mkdir $APPS_DIR

# install zsh
RUN yum install -y zsh



# install rvm and ruby
ENV PATH "/usr/local/rvm/bin:${PATH}"

RUN yum install -y patch \
                   autoconf \
                   automake \
                   bison \
                   bzip2 \
                   gcc-c++ \
                   libffi-devel \
                   libtool \
                   make \
                   readline-devel \
                   ruby \
                   sqlite-devel \
                   zlib-devel \
                   glibc-headers \
                   glibc-devel \
                   libyaml-devel \
                   openssl-devel

RUN command curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import - \
  #&& mkdir -p $RVM_DIR/scripts/rvm \
  && curl -sSL https://get.rvm.io | bash -s -- --ignore-dotfiles stable \
  && source /usr/local/rvm/bin/rvm \ # $RVM_DIR/scripts/rvm | bash \
  && rvm --trace install $RUBY_VERSION \
  && rvm alias create default $RUBY_VERSION



# install pyenv and python
ENV PYENV_ROOT /usr/local/bin/pyenv
ENV PATH /usr/local/bin/pyenv/versions/$PYTHON_VERSION/bin:$PYENV_ROOT/bin:$PATH

RUN git clone https://github.com/pyenv/pyenv.git /usr/local/bin/pyenv \
  && yum install -y gcc \
                    command \
                    zlib-devel \
                    bzip2 \
                    bzip2-devel \
                    readline-devel \
                    sqlite \
                    sqlite-devel \
                    tk-devel \
                    libffi-devel \
                    openssl \
                    openssl-devel \
                    patch \
                    make \
  && pyenv install -v $PYTHON_VERSION \
  && pyenv global $PYTHON_VERSION



# install nvm and node
RUN mkdir -p $NVM_DIR \
  && git clone https://github.com/nvm-sh/nvm.git $NVM_DIR | bash \
  && cd $NVM_DIR && git checkout $NVM_VERSION \
  && . $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default

# install develper tools

# install neovim
RUN wget https://github.com/neovim/neovim/releases/download/v$NEOVIM_VERSION/nvim-linux64.tar.gz \
  && tar -xf ./nvim-linux64.tar.gz -C $APPS_DIR \
  && rm ./nvim-linux64.tar.gz

# needed for mounting init.vim
RUN mkdir -p $HOME_DIR/.config/nvim \
  && mkdir -p $HOME_DIR/.config/coc

# install tmux 
RUN yum install -y tmux

# install vim-plug
RUN mkdir -p $APPS_DIR/vim-plugged/autoload \
  && curl -fLo $APPS_DIR/vim-plugged/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | bash


# install tmuxinator
#RUN gem install tmuxinator | bash


USER unicorn 
