# Usage:
# docker build --build-arg DOTFILES=v.1.13.5 -t u1and0/archlinux .
# docker run -it --rm -v `pwd`:/work -w /work u1and0/archlinux

FROM oblique/archlinux-yay:latest

# Japanese setting
ENV LANG="ja_JP.UTF8"\
    LC_NUMERIC="ja_JP.UTF8"\
    LC_TIME="ja_JP.UTF8"\
    LC_MONETARY="ja_JP.UTF8"\
    LC_PAPER="ja_JP.UTF8"\
    LC_MEASUREMENT="ja_JP.UTF8"

# Get reflector Server setting for faster download
# `reflector --verbose --country Japan -l 10 --sort rate`
COPY mirrorlist /etc/pacman.d/mirrorlist
RUN echo ja_JP.UTF-8 UTF-8 > /etc/locale.gen &&\
    locale-gen &&\
    : "Set time locale, Do not use 'timedatectl set-timezone Asia/Tokyo'" &&\
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime &&\
    : "Permission fix" &&\
    chmod -R 755 /etc/pacman.d &&\
    pacman -Syyu --noconfirm git openssh &&\
    : "Remove caches forcely" &&\
    yes | pacman -Scc
    
# My dotfiles
ARG HOME="/root"
WORKDIR "${HOME}"
ARG DOTFILES=master
RUN git clone -b $DOTFILES --depth 1\
    https://github.com/u1and0/dotfiles.git &&\
    : "Replace dotfiles" &&\
    mv -i "${HOME}/dotfiles/.git" "${HOME}" &&\
    git reset --hard &&\
    rm -rf "${HOME}/dotfiles" &&\
    rmdir ${HOME}/{bacpac,pyenv}

CMD ["/bin/bash"]

LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="archlinux container. aur install by yay. sudo -u aur yay -S {package}"\
      description.ja="Archlinux コンテナ。yayによるaurインストール可能. sudo -u aur yay -S {package}, dotfiles master branch"\
      version="arlhlinux:v1.1.0"
