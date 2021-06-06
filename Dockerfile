# Usage:
# docker run -it --rm -v `pwd`:/work -w /work u1and0/archlinux
#
# For building:
# docker build --build-arg branch="v1.15.1" -t u1and0/archlinux .

FROM archlinux

# Get reflector Server setting for faster download
# Same as `reflector --verbose --country Japan -l 10 --sort rate`
COPY mirrorlist /etc/pacman.d/mirrorlist

# Japanese setting
ARG SETLANG="ja_JP"
ENV LANG="${SETLANG}.UTF8"\
    LC_NUMERIC="${SETLANG}.UTF8"\
    LC_TIME="${SETLANG}.UTF8"\
    LC_MONETARY="${SETLANG}.UTF8"\
    LC_PAPER="${SETLANG}.UTF8"\
    LC_MEASUREMENT="${SETLANG}.UTF8"

# Locale setting
ARG GLIBVER="2.33"
ARG LOCALETIME="Asia/Tokyo"
RUN : "Copy missing language pack '${SETLANG}'" &&\
    curl http://ftp.gnu.org/gnu/libc/glibc-${GLIBVER}.tar.bz2 | tar -xjC /tmp &&\
    cp /tmp/glibc-${GLIBVER}/localedata/locales/${SETLANG} /usr/share/i18n/locales/ &&\
    rm -rf /tmp/* &&\
    : "Overwrite locale-gen" &&\
    echo ${SETLANG}.UTF-8 UTF-8 > /etc/locale.gen &&\
    locale-gen &&\
    : "Set time locale, Do not use 'timedatectl set-timezone Asia/Tokyo'" &&\
    ln -fs /usr/share/zoneinfo/${LOCALETIME} /etc/localtime

RUN : "Fix pacman.conf" &&\
    sed -ie 's/#Color/Color/' /etc/pacman.conf &&\
    pacman -Syy --noconfirm archlinux-keyring &&\
    pacman -Su --noconfirm git openssh base-devel &&\
    : "Clear cache" &&\
    pacman -Qtdq | xargs -r pacman --noconfirm -Rcns

ARG USERNAME=u1and0
# docker build --Build-arg USERNAME=${USERNAME} -t u1and0/archlinux .
ARG UID=1000
ARG GID=1000
RUN echo "Build start with USERNAME: $USERNAME UID: $UID GID: $GID" &&\
    : "Add yay option" &&\
    echo '[multilib]' >> /etc/pacman.conf &&\
    echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf &&\
    pacman -Sy &&\
    : "Add user ${USERNAME} for yay install" &&\
    groupadd -g ${GID} ${USERNAME} &&\
    useradd -u ${UID} -g ${GID} -m -s /bin/bash ${USERNAME} &&\
    passwd -d ${USERNAME} &&\
    mkdir -p /etc/sudoers.d &&\
    touch /etc/sudoers.d/${USERNAME} &&\
    echo "${USERNAME} ALL=(ALL) ALL" > /etc/sudoers.d/${USERNAME} &&\
    mkdir -p /home/${USERNAME}/.gnupg &&\
    echo 'standard-resolver' > /home/${USERNAME}/.gnupg/dirmngr.conf &&\
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} &&\
    mkdir /build &&\
    chown -R ${USERNAME}:${USERNAME} /build

# yay install
WORKDIR "/build"
RUN sudo -u ${USERNAME} git clone --depth 1 https://aur.archlinux.org/yay.git
WORKDIR "/build/yay"
RUN sudo -u ${USERNAME} makepkg --noconfirm -si &&\
    sudo -u ${USERNAME} yay --afterclean --removemake --save &&\
    pacman -Qtdq | xargs -r pacman --noconfirm -Rcns &&\
    : "Remove caches forcely" &&\
    : "[error] yes | pacman -Scc" &&\
    rm -rf /home/${USERNAME}/.cache &&\
    rm -rf /build


# My dotfiles
WORKDIR /home/${USERNAME}
USER ${USERNAME}
# `--build-arg=branch=v1.15.1` のようにしてブランチ名、タグ名指定しなければ
# デフォルトではmasterブランチをcloneしてくる
ARG branch=master
RUN git clone --branch $branch\
    https://github.com/u1and0/dotfiles.git dotfiles &&\
    : "Replace dotfiles" &&\
    mv -f dotfiles/.git . &&\
    git reset --hard &&\
    rm -rf dotfiles

CMD ["/bin/bash"]

LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="archlinux container. aur install by yay. yay -S {package}"\
      description.ja="Archlinux コンテナ。yayによるaurインストール可能. yay -S {package}, dotfiles master branch"\
      version="arlhlinux:5.0.0"
