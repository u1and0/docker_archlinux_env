# Usage:
# docker run -it --rm -v `pwd`:/work -w /work u1and0/archlinux
#
# For building:
# docker build --build-arg BASE="2019.01.01"\
#   BRANCH="v1.13.5" USER="u1and0" -t u1and0/archlinux .

ARG BASE="2018.09.01"
FROM base/archlinux:${BASE}

# Japanese setting
ENV LANG="ja_JP.UTF8"\
    LC_NUMERIC="ja_JP.UTF8"\
    LC_TIME="ja_JP.UTF8"\
    LC_MONETARY="ja_JP.UTF8"\
    LC_PAPER="ja_JP.UTF8"\
    LC_MEASUREMENT="ja_JP.UTF8"
# Get reflector Server setting for faster download
# Same as `reflector --verbose --country Japan -l 10 --sort rate`
COPY mirrorlist /etc/pacman.d/mirrorlist
RUN echo ja_JP.UTF-8 UTF-8 > /etc/locale.gen &&\
    locale-gen &&\
    : "Set time locale, Do not use 'timedatectl set-timezone Asia/Tokyo'" &&\
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime &&\
    : "Permission fix" &&\
    chmod -R 755 /etc/pacman.d &&\
    pacman -Syy --noconfirm git openssh base-devel &&\
    : "Add yay option" &&\
    echo '[multilib]' >> /etc/pacman.conf &&\
    echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf &&\
    : "Add user aur for yay install" &&\
    useradd -m -r -s /bin/bash aur &&\
    passwd -d aur &&\
    echo 'aur ALL=(ALL) ALL' > /etc/sudoers.d/aur &&\
    mkdir -p /home/aur/.gnupg &&\
    echo 'standard-resolver' > /home/aur/.gnupg/dirmngr.conf &&\
    chown -R aur:aur /home/aur &&\
    mkdir /build &&\
    chown -R aur:aur /build &&\
    yes | pacman -Scc

# yay install
WORKDIR "/build"
RUN sudo -u aur git clone --depth 1 https://aur.archlinux.org/yay.git
WORKDIR "/build/yay"
RUN pacman -Syy --noconfirm base-devel &&\
    sudo -u aur makepkg --noconfirm -si &&\
    sudo -u aur yay --afterclean --removemake --save &&\
    pacman -Qtdq | xargs -r pacman --noconfirm -Rcns &&\
    : "Remove caches forcely" &&\
    yes | pacman -Scc &&\
    rm -rf /home/aur/.cache &&\
    rm -rf /build


# My dotfiles
ARG HOME="/root"
WORKDIR "${HOME}"
ARG BRANCH="master"
ARG USER="u1and0"
RUN git clone -b ${BRANCH} --depth 1\
    https://github.com/${USER}/dotfiles.git &&\
    : "Replace dotfiles" &&\
    mv -i "${HOME}/dotfiles/.git" "${HOME}" &&\
    git reset --hard &&\
    rm -rf "${HOME}/dotfiles" &&\
    rmdir ${HOME}/{bacpac,pyenv}

CMD ["/bin/bash"]

LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="archlinux container. aur install by yay. sudo -u aur yay -S {package}"\
      description.ja="Archlinux コンテナ。yayによるaurインストール可能. sudo -u aur yay -S {package}, dotfiles master branch"\
      version="arlhlinux:2019.01.01"
