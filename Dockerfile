FROM base/archlinux
MAINTAINER u1and0 <e01.ando60@gmail.com>

# Setup pacman
RUN pacman -Syu --noconfirm reflector
# Backup of original mirrorlist
RUN cp /etc/pacman.d/mirrorlist{,.bac}
RUN reflector --verbose --country 'Japan' -l 10 --sort rate --save /etc/pacman.d/mirrorlist

RUN pacman -Syu --noconfirm sudo git openssh vi zsh

# Create user `docker`, switch to user and set directory to their home.
ARG USERNAME="docker"
RUN useradd -m -d /home/$USERNAME  -g users -G users,wheel $USERNAME

# Normal user treat as root user.
RUN sed -ie 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

# Change user
USER $USERNAME
WORKDIR /home/$USERNAME
CMD ["zsh"]
