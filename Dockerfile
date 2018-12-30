FROM base/archlinux

# Get reflector
RUN pacman -Sy && pacman -S --noconfirm reflector
# Server setting
RUN reflector --verbose --latest 200 --sort rate --save /etc/pacman.d/mirrorlist

RUN pacman -Syu --noconfirm git openssh vim

ARG HOME="/root"
WORKDIR "${HOME}"

RUN git clone -b v1.12.0 --depth 1\
        https://github.com/u1and0/dotfiles.git &&\
        mv -i "${HOME}/dotfiles/.git" "${HOME}" &&\
        git reset --hard &&\
        rm -rf "${HOME}/dotfiles"

ENV LANG="ja_JP.UTF8"\
    LC_NUMERIC="ja_JP.UTF8"\
    LC_TIME="ja_JP.UTF8"\
    LC_MONETARY="ja_JP.UTF8"\
    LC_PAPER="ja_JP.UTF8"\
    LC_MEASUREMENT="ja_JP.UTF8"
RUN echo ja_JP.UTF-8 UTF-8 > /etc/locale.gen &&\
    locale-gen && pacman -Syy


CMD ["/bin/bash"]


LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="archlinux container. minimum develop env enabling git.locale=ja_jp env."\
      description.ja="Archlinux コンテナ。git使用可能な最小限開発環境.日本語対応 "\
      version="arlhlinux:v0.4.1"
