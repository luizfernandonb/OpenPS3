# !/bin/sh

openps3_path=/opt/OpenPS3

if [ ! -d "$openps3_path" ]; then
	printf "ERROR: Please create the '$openps3_path' folder to compile and install the toolchain.\n"
	exit 1
fi

if [ $(ls -ld $openps3_path | awk '{print $3}') != $USER ]; then
	printf "Please change the owner of the '$openps3_path' folder to yourself, to do this, run the command\n\nsudo chown -R $USER $openps3_path\n"
	exit 1
fi

this_script_current_path=$(dirname -- $0)

#if [ ! -d "$this_script_current_path/binutils-gdb" ] || [ ! -d "$this_script_current_path/gcc" ]; then
if [ ! -d "$this_script_current_path/binutils-gdb" ]; then
	printf "ERROR: Submodule folders were not found, please run 'git submodule update --init' command to clone the missing repositories.\n"
	exit 1
fi

rm -rfv $openps3_path/*
rm -rfv $this_script_current_path/binutils-gdb/build/* $this_script_current_path/gcc/build/*
mkdir -pv $this_script_current_path/binutils-gdb/build $this_script_current_path/gcc/build

target=ps3-ppu

# ========== binutils ==========
pushd $this_script_current_path/binutils-gdb/build &&

patch --verbose -N -d .. -p0 < ../../patches/binutils-gdb.patch || true &&

CFLAGS="-Ofast -ffunction-sections -fdata-sections -Wl,--gc-sections -m64 -march=x86-64 -pipe" \
CXXFLAGS="$CFLAGS" \
../configure \
	--prefix="$openps3_path" \
	--datarootdir="$openps3_path/$target" \
	--bindir="$openps3_path/$target/bin" \
	--libdir="$openps3_path/$target/lib" \
	--target="$target" \
	--disable-dependency-tracking \
	--disable-gdb \
	--disable-sim \
	--disable-gprof \
	--with-gnu-ld \
	--with-pkgversion="OpenPS3" \
	--with-bugurl="https://github.com/luizfernandonb/OpenPS3/issues" &&
make all -j$(nproc) &&
make check -j$(nproc) &&
make install-strip -j$(nproc) &&

popd
# ==============================
