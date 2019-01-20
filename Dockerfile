FROM oblique/archlinux-yay:latest

# Get reflector Server setting
RUN pacman -Sy --noconfirm reflector &&\
    reflector --verbose --latest 200 --sort rate --save /etc/pacman.d/mirrorlist

RUN pacman -Syu --noconfirm git openssh vim

# directories
ARG HOME="/root"
WORKDIR "${HOME}"

# Japanese setting
ENV LANG="ja_JP.UTF8"\
    LC_NUMERIC="ja_JP.UTF8"\
    LC_TIME="ja_JP.UTF8"\
    LC_MONETARY="ja_JP.UTF8"\
    LC_PAPER="ja_JP.UTF8"\
    LC_MEASUREMENT="ja_JP.UTF8"
RUN echo ja_JP.UTF-8 UTF-8 > /etc/locale.gen &&\
    locale-gen && pacman -Syy

# My dotfiles
RUN git clone -b v1.12.0 --depth 1\
        https://github.com/u1and0/dotfiles.git &&\
        mv -i "${HOME}/dotfiles/.git" "${HOME}" &&\
        git reset --hard &&\
        rm -rf "${HOME}/dotfiles"

# Reinstall packages required by zplug
RUN pacman -Sy --noconfirm zsh awk git &&\
    eval zsh -l

CMD ["/usr/bin/zsh"]


LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="archlinux container. aur install by yay."\
      description.ja="Archlinux コンテナ。yayによるaurインストール可能"\
      version="arlhlinux:v1.0.0"
