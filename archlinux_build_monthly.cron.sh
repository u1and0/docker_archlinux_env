#!/bin/sh
#
# build Dockerfile base/archlinux:{tagname} on dockerhub
# by pushing github
#
TAG="$(date +%Y.%m.01)"
DIR=$(dirname "$0")

# Checkout
cd ${DIR}
git checkout master

# Modify
sed -i -e "s/latest/${TAG}/" Dockerfile
git commit -am "base version ${TAG}"
git tag ${TAG}
sudo -u u1and0 git push origin "${TAG}"

# Return
sed -i -e "s/${TAG}/latest/" Dockerfile
git commit -am "base version latest"
