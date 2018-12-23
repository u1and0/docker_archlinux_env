FROM base/archlinux

# Get reflector
RUN pacman -Sy && pacman -S --noconfirm reflector
# Server setting
RUN cp /etc/pacman.d/mirrorlist{,.bac} &&\
    reflector --verbose --latest 200 --sort rate --save /etc/pacman.d/mirrorlist
# reflector --verbose --country 'Japan' -l 10

CMD ["/bin/bash"]


LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="archlinux container. Rebuild pacman server sort by rate"\
      description.ja="Archlinux コンテナ。pacmanサーバーをレート順に再構築"\
      version="archlinux:v0.1.1"
