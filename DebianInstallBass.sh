#!/usr/bin/env bash
cp libbass.so /usr/local/lib
chmod a+rx /usr/local/lib/libbass.so
ldconfig

apt-get update
apt-get install libasound2 libopenal1 libalut0 libglu1-mesa libgles1-mesa libgles2-mesa libgl2ps1 libglew2.0 libglfw3
# For dev:
# apt-get install libasound2-dev libopenal-dev libalut-dev libgl1-mesa-dev libglu1-mesa-dev libgles1-mesa-dev libgles2-mesa-dev libgl2ps-dev libglew-dev libglfw3-dev
