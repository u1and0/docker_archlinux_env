FROM base/archlinux

# Get reflector
RUN pacman -Sy && pacman -S --noconfirm reflector
# Server setting
RUN cp /etc/pacman.d/mirrorlist{,.bac} &&\
    reflector --verbose --latest 200 --sort rate --save /etc/pacman.d/mirrorlist
# reflector --verbose --country 'Japan' -l 10

RUN pacman -S --noconfirm git openssh vim

CMD ["/bin/bash"]


LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="archlinux container. minimum develop env enabling git"\
      description.ja="Archlinux コンテナ。git使用可能な最小限開発環境"\
      version="archlinux:v0.2.1"
