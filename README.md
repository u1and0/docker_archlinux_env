Dockerfile for [u1nd0/archlinux](https://cloud.docker.com/repository/docker/u1and0/archlinux)

# Install

```
docker pull u1and0/archlinux
docker run -it --rm -v `pwd`:/work -w /work u1and0/archlinux
```

# Version
v0.5.0: yay install & dotfiles version v1.13.1


# Description
* Archlinux コンテナ
* yayによるaurインストール可能
  * sudo -u aur yay -S {package}
* dotfiles v1.13.1
