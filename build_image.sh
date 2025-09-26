#!/bin/bash

# build_image.sh
IMG_NAME="kokoro" #


# 获取架构
ARCH=$(uname -m)

case "$ARCH" in
  aarch64)
    if [[ -f "/etc/nv_tegra_release" ]] || grep -qi "nvidia" /proc/device-tree/model 2>/dev/null; then
      ARCH_TAG="jet"
    else
      ARCH_TAG="arm"
    fi
    ;;
  x86_64)
    ARCH_TAG="amd"
    ;;
  *)
    ARCH_TAG="unknown"
    ;;
esac

# 获取日期
DATE=$(date +%Y%m%d)

# 检查 version.txt
if [[ -f "VERSION" ]]; then
    VERSION=$(cat version.txt | tr -d ' \t\n\r')
    TAG="${ARCH_TAG}_${VERSION}_${DATE}"
    echo "Using version from version.txt: ${VERSION}"
else
    TAG="${ARCH_TAG}_${DATE}"
    echo "No version.txt found, using default tag format."
fi


# 构建并推送镜像
docker build -t swr.cn-southwest-2.myhuaweicloud.com/ictrek/${IMG_NAME}:${TAG} -f Dockerfile .

docker push swr.cn-southwest-2.myhuaweicloud.com/ictrek/${IMG_NAME}:${TAG}