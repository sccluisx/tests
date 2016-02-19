#!/bin/bash
cd ext/yaggo
make DEST=$PWD/bin
PATH=$PATH:$PWD
export PATH
cd ../..

cd ext/jellyfish/
autoreconf -i
./configure --prefix=$PWD/jellybin
make -j 4
make install

cd ../..
autoreconf -i
./configure
make
