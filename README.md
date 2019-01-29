Dockerfile for [u1and0/archlinux](http://hub.docker.com/r/u1and0/archlinux)

![screen](https://raw.githubusercontent.com/u1and0/docker_archlinux_env/screenshot/Screenshot%20from%202019-01-29%2022-51-31.png)

# Install & Run

```
docker pull u1and0/archlinux
docker run -it --rm -v `pwd`:/work -w /work u1and0/archlinux
```

# Version
v0.7.1          [add] screenshot & [mod] url
v0.7.0          designated by DOTFILES arg when building
v0.6.0          [add] usage, branch=master
v0.5.0           yay install & dotfiles version v1.13.1


# Description
* Archlinux コンテナ
* yayによるaurインストール可能
  * `sudo -u aur yay -S {package}`
* buildするときはdotfilesのバージョンを指定する
  * `docker build --build-arg DOTFILES=v1.13.3 -t u1and0/archlinux .`
