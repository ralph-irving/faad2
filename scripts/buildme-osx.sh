#!/bin/sh

FAAD=2.7
LOG=$PWD/config.log
CHANGENO=`git rev-parse --short HEAD`

# Build Intel half first
echo "Building Intel binary..."
ARCH=i386

# Mac Universal Binary support

## Start
echo "Most log mesages sent to $LOG... only 'errors' displayed here"
date > $LOG

## Build
echo "Cleaning up..."
rm -rf faad-i386 faad-ppc
make distclean >> $LOG

echo "Configuring..."
CC=i686-apple-darwin10-gcc-4.0.1 \
CXX=i686-apple-darwin10-g++-4.0.1 \
CFLAGS="-s -O3 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -arch $ARCH" \
CPPFLAGS="${CFLAGS}" \
CXXFLAGS="${CFLAGS}" \
LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch $ARCH -mmacosx-version-min=10.4" \
HAVE_BMP_TRUE=0 \
./configure --without-xmms --without-drm --without-mpeg4ip --enable-static=yes --enable-shared=no --disable-dependency-tracking --prefix=/usr/local >> $LOG

echo "Running make"
make >> $LOG

# Copy faad binary out
cp -p frontend/faad faad-$ARCH || exit

make distclean >> $LOG

# Build PPC half
echo "Building PPC binary..."
ARCH=ppc

echo "Configuring..."

# Mac Universal Binary support
CC=powerpc-apple-darwin10-gcc \
CXX=powerpc-apple-darwin10-g++ \
CFLAGS="-s -O3 -D__BIG_ENDIAN__ -isysroot /Developer/SDKs/MacOSX10.4u.sdk -mcpu=G3 -arch $ARCH" \
CPPFLAGS="${CFLAGS}" \
CXXFLAGS="${CFLAGS}" \
LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch $ARCH -mmacosx-version-min=10.3" \
HAVE_BMP_TRUE=0 \
./configure --without-xmms --without-drm --without-mpeg4ip --enable-static=yes --enable-shared=no --disable-dependency-tracking --prefix=/usr/local >> $LOG

echo "Running make"
make >> $LOG

# Copy faad binary out
cp -p frontend/faad faad-$ARCH

# Combine them
strip faad-i386
strip faad-ppc
lipo -create faad-i386 faad-ppc -output faad-$CHANGENO
