#!/bin/bash
set -e

BUILD_PACKAGES_ONLY=0
if [ "$1" = "-packages" ]; then
    BUILD_PACKAGES_ONLY=1
fi

install_deps() {
    export DEBIAN_FRONTEND=noninteractive
    sudo -E apt-get update -qq
    sudo -E apt-get install -y --no-install-recommends \
        build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
        gettext git libncurses5-dev libssl-dev python3-setuptools rsync swig \
        unzip zlib1g-dev file wget python3-cryptography mkbootimg qemu-utils \
        asciidoc help2man xsltproc bc binutils bzip2 make patch time \
        device-tree-compiler e2fsprogs fdisk util-linux nano perl perl-modules python3-dev \
        xz-utils zstd zip libelf-dev libfdt-dev
}

install_deps

if [ ! -d "openwrt" ]; then
    VERSION=$(git ls-remote --tags https://git.openwrt.org/openwrt/openwrt.git 'v25.12.*' | grep -oP 'v25\.12\.\d+$' | sort -V | tail -1)
    if [ -z "$VERSION" ]; then
        echo "Failed to fetch the latest OpenWrt version."
        exit 1
    fi
    echo "Cloning OpenWrt ($VERSION)..."
    git clone https://git.openwrt.org/openwrt/openwrt.git "openwrt"
    git -C "openwrt" checkout "$VERSION"
else
    echo "Folder openwrt already exists, skipping clone."
fi

echo "Applying patches and copying files..."
chmod +x apply_patches.sh
./apply_patches.sh "openwrt"

mkdir -p "openwrt/target/linux/msm89xx"
mkdir -p "openwrt/package/msm8916"
cp -a msm89xx/* "openwrt/target/linux/msm89xx/"
cp -a packages/* "openwrt/package/msm8916/"

cd openwrt

echo "Updating feeds..."
./scripts/feeds update -a >/dev/null
./scripts/feeds install -a >/dev/null

echo "Applying configuration (diffconfig_uz801)..."
cp ../diffconfig_uz801 .config
make defconfig

CORES=$(nproc 2>/dev/null || echo 2)
echo "Starting build with $CORES cores..."
make download -j"$CORES"

if [ $BUILD_PACKAGES_ONLY -eq 1 ]; then
    echo "Building packages only"
    make tools/install -j"$CORES"
    make toolchain/install -j"$CORES"
    make target/linux/compile -j"$CORES" || make target/linux/compile -j1 V=s

    echo "Building custom packages..."
    for pkg_dir in ../packages/*; do
        if [ -d "$pkg_dir" ]; then
            pkg_name=$(basename "$pkg_dir")
            echo "-> Building $pkg_name..."
            make "package/msm8916/$pkg_name/compile" -j"$CORES" || make "package/msm8916/$pkg_name/compile" -j1 V=s
        fi
    done
    echo "Packages build done! Look for them in openwrt/bin/packages/"
else
    make -j"$CORES" || make -j1 V=s
    echo "Firmware build done! Look for it in openwrt/bin/targets/msm89xx/msm8916/"
fi\