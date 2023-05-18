if grep -q "ID_LIKE=arch" /etc/os-release; then
sudo pacman -Syu --noconfirm nasm qemu-full base-devel gmp libmpc mpfr
else
echo "does not got arch!"
exit
fi

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
TEMP="$PWD/temp"

BINUTILS_VERSION="2.40"
BINUTILS_TAR="binutils-$BINUTILS_VERSION.tar.gz"
BINUTILS_DOWNLOAD_URL="https://ftp.gnu.org/gnu/binutils/$BINUTILS_TAR"

GCC_VERSION="13.1.0"
GCC_TAR="gcc-$GCC_VERSION.tar.gz"
GCC_DOWNLOAD_URL="https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/$GCC_TAR"

mkdir -p $TEMP

wget $BINUTILS_DOWNLOAD_URL -P $TEMP
wget $GCC_DOWNLOAD_URL -P $TEMP

tar -xvzf $TEMP/$BINUTILS_TAR -C $TEMP
tar -xvzf $TEMP/$GCC_TAR -C $TEMP

mkdir -p $HOME/src

cd $HOME/src
mkdir build-binutils
cd build-binutils
$TEMP/binutils-$BINUTILS_VERSION/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install

cd $HOME/src
mkdir build-gcc
cd build-gcc
$TEMP/gcc-$GCC_VERSION/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc

sudo ln -s $HOME/opt/cross/bin/* /usr/bin

rm -rf $TEMP