#!/usr/bin/env bash
cp libbass.so /usr/local/lib
chmod a+rx /usr/local/lib/libbass.so
ldconfig

apt-get update
apt-get install libasound2 libopenal1 libalut0 libgles2-mesa
