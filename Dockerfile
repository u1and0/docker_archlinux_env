# Usage:
# $ docker run -it --rm -v `pwd`:/work -w /work u1and0/archlinux
#
# For building:
# $ git clone https://github.com/u1and0/docker_archlinux_env
# $ docker build --build-arg USERNAME=${USERNAME} --build-arg branch="develop" -t u1and0/archlinux .

# Archlinux official image daily build version
FROM menci/archlinuxarm:base-devel

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

# Package update
RUN pacman -Sy --noconfirm archlinux-keyring &&\
    pacman -Syu --noconfirm git openssh &&\
    : "Clear cache" &&\
    pacman -Qtdq | xargs -r pacman --noconfirm -Rcns

ARG USERNAME=u1and0
# docker build --build-arg USERNAME=${USERNAME} -t u1and0/archlinux .
ARG UID=1000
ARG GID=1000
RUN echo "Build start with USERNAME: $USERNAME UID: $UID GID: $GID" &&\
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
# COPY --from=u1and0/yay:arm64 /usr/bin/yay /usr/bin/yay

# My dotfiles
WORKDIR /home/${USERNAME}
USER ${USERNAME}
# `--build-arg=branch=v1.15.1` のようにしてブランチ名、タグ名指定しなければ
# デフォルトではmasterブランチをcloneしてくる
ARG branch="master"
RUN git clone --branch $branch\
    https://github.com/u1and0/dotfiles.git dotfiles &&\
    : "Replace dotfiles" &&\
    mv -f dotfiles/.git . &&\
    git reset --hard &&\
    rm -rf dotfiles

CMD ["/bin/bash"]

LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="archlinux image. AUR packages are able to install by yay. yay -S {package}"\
      description.ja="Archlinux イメージ。yayによるAURパッケージインストール可能. yay -S {package}, dotfiles develop branch"\
      version="arlhlinux:6.0.0arm"
