#!/bin/sh

FAAD=2.7
LOG=$PWD/config.log
CHANGENO=`git rev-parse --short HEAD`
ARCH=`arch`
OUTPUT=$PWD/faad2-build-$ARCH-$CHANGENO
export CFLAGS="-O2 -s"
export CXXFLAGS="$CFLAGS"
export LIBS="-lssp"

# Clean up
rm -rf $OUTPUT

## Start
echo "Most log messages sent to $LOG... only 'errors' displayed here"
date > $LOG

## Build
echo "Cleaning up..."
make distclean >> $LOG

if [ ! -d autom4te.cache ]; then
echo "Autogen..."
./bootstrap
fi

echo "Configuring..."
./configure --without-xmms --without-drm --without-mpeg4ip --enable-static=yes --enable-shared=no --prefix=/usr/local >> $LOG

echo "Building..."
mkdir -p $OUTPUT
make DESTDIR=$OUTPUT install >> $LOG

## Tar the whole package up
tar -zcvf $OUTPUT.tgz $OUTPUT
rm -rf $OUTPUT
