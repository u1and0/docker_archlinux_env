FROM base/archlinux

# Get reflector
RUN pacman -Sy && pacman -S --noconfirm reflector
# Server setting
RUN cp /etc/pacman.d/mirrorlist{,.bac} &&\
    reflector --verbose --latest 200 --sort rate --save /etc/pacman.d/mirrorlist
# reflector --verbose --country 'Japan' -l 10

RUN pacman -S --noconfirm git openssh vim

ARG HOME="/root"
WORKDIR "${HOME}"

RUN git clone --depth 1\
        https://github.com/u1and0/dotfiles.git &&\
        mv -i "${HOME}/dotfiles/.git" "${HOME}" &&\
        git reset --hard &&\
        rm -rf "${HOME}/dotfiles"

CMD ["/bin/bash"]


LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="archlinux container. dotfiles installed."\
      description.ja="Archlinux コンテナ.自分用dotfiles適用済み"\
      version="archlinux:v0.3.0"
