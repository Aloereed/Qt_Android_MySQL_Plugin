#!/bin/bash

# Edit these lines

export NDK_ROOT="/home/rush/Android/Sdk/ndk-r10e"
export QT_ROOT="/home/rush/Qt/5.9.3"

SR="$NDK_ROOT/platforms/android-21/arch-arm"
BR="$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-"
# BR="$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/windows-x86_64/bin/arm-linux-androideabi-"
platform=android-armv7
platform_sort=arm
# qmake of new Qt is in dir below
qmake="$QT_ROOT/android/bin/qmake"

libiconv_pkg=libiconv-1.14.tar.gz
openssl_pkg=openssl-1.0.2j.tar.gz
mariadb_pkg=mariadb-connector-c-2.3.2-src.tar.gz

# Don't edit after this line

# libiconv compile
dir=$(basename $libiconv_pkg .tar.gz)

rm -r $dir
tar -xf $libiconv_pkg || exit 1

pushd $dir
        STRIP="$BR"strip RANLIB="$BR"ranlib OBJDUMP="$BR"objdump AR="$BR"ar CC="$BR"gcc CFLAGS=--sysroot=$SR CPP="$BR"cpp CPPFLAGS=$CFLAGS ./configure --host=$platform_sort --prefix=$SR/usr --with-sysroot=$SR
        make || exit 1
        make install || exit 1
popd

echo
echo "libiconv compiled !!!"
echo
rm -r $dir

# openssl compile
dir=$(basename $openssl_pkg .tar.gz)

rm -r $dir
tar -xf $openssl_pkg || exit 1

pushd $dir
        RANLIB="$BR"ranlib CC="$BR"gcc ./Configure $platform --prefix=$SR/usr
        ANDROID_DEV=$SR/usr make || exit 1
        make install_sw || exit 1
popd

echo
echo "openssl compiled !!!"
echo
rm -r $dir

# mariadb compile
# must be acted in Linux or WSL
dir=$(basename $mariadb_pkg .tar.gz)

rm -r $dir
tar -xf $mariadb_pkg || exit 1

pushd $dir
        sed -i -e "s|ADD_SUBDIRECTORY(unittest/libmariadb)|#ADD_SUBDIRECTORY(unittest/libmariadb)|" CMakeLists.txt
        sed -i -e "N; s|#define _global_h|#define _global_h\n\n#ifndef ushort\n#define ushort uint16\n#endif|" include/my_global.h
        sed -i -e "N; s|SET_TARGET_PROPERTIES(libmariadb PROPERTIES VERSION.*||" libmariadb/CMakeLists.txt
        sed -i -e "N; s|SOVERSION \${CPACK_PACKAGE_VERSION_MAJOR})||" libmariadb/CMakeLists.txt 
        sed -i -e "N; s|\${CPACK_PACKAGE_VERSION_MAJOR}||" libmariadb/CMakeLists.txt
        mkdir build
        pushd build
        PKG_CONFIG_PATH=$SR/usr/lib/pkgconfig cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS=--sysroot="$SR" \
		-DCMAKE_INSTALL_PREFIX="$SR/usr" \
		-DCMAKE_C_COMPILER="$BR"gcc \
		-DCMAKE_LINKER="$BR"ld \
		-DCMAKE_AR="$BR"ar \
		-DCMAKE_NM="$BR"nm \
		-DCMAKE_OBJCOPY="$BR"objcopy \
		-DCMAKE_OBJDUMP="$BR"objdump \
		-DCMAKE_RANLIB="$BR"ranlib \
		-DCMAKE_STRIP="$BR"strip \
		-DICONV_INCLUDE_DIR="$SR/usr/include" \
		-DICONV_LIBRARIES="$SR/usr/lib/libiconv.a" \
		-DWITH_EXTERNAL_ZLIB=ON \
		-DZLIB_INCLUDE_DIR="$SR/usr/include" \
		-DZLIB_LIBRARY="$SR/usr/lib/libz.so" ../ || exit 1
        pushd include        
		sed -i -e "N; s|#define HAVE_UCONTEXT_H 1|/* #undef HAVE_UCONTEXT_H */|" my_config.h
		sed -i -e "N; s|#define HAVE_GETPWNAM 1|/* #undef HAVE_GETPWNAM */|" my_config.h
		sed -i -e "N; s|#define HAVE_STPCPY 1|/* #undef HAVE_STPCPY */|" my_config.h
		popd
		make || exit 1
		make install || exit 1
		popd
popd

echo
echo "mariadb compiled !!!"
echo
rm -r $dir

# qt mariadb driver compile 
export ANDROID_NDK_ROOT=$NDK_ROOT

[ ! -f "$qmake" ] && { echo "Could not find qmake in '$qmake'"; exit 1; }
[ ! -x "$qmake" ] && { echo "Qmake is not executable in '$qmake'"; exit 1; }

# Backup & Fix Qt MySQL projects
cp $QT_ROOT/Src/qtbase/src/plugins/sqldrivers/mysql/mysql.pro $QT_ROOT/Src/qtbase/src/plugins/sqldrivers/mysql/mysql_orig.pro
cp ./android_mysql.pro $QT_ROOT/Src/qtbase/src/plugins/sqldrivers/mysql/mysql.pro

restore() {
        cp ./mysql_orig.pro ./mysql.pro
        rm ./mysql_orig.pro
}

restore_and_exit() {
        restore
        exit 1
}
        
pushd $QT_ROOT/Src/qtbase/src/plugins/sqldrivers/mysql/
        make clean
        $qmake "INCLUDEPATH+=$SR/usr/include/mariadb" "LIBS+=-L$SR/usr/lib/mariadb -lmysqlclient_r" -o Makefile mysql.pro
        make || restore_and_exit
        make install || restore_and_exit
        restore
popd
# sometimes libmysqlclient_r.so is empty, you need to copy libmariadb.so to it. (They are the same.)
echo
echo "qt mariadb driver compiled !!!"
echo

