#!/bin/bash
#Yaggo installation
echo "Compiling Yaggo"
cd ext/yaggo
make DEST=$PWD/bin
PATH=$PATH:$PWD
export PATH
cd ../..
#Jellyfish installation
echo "Compiling Jellyfish"
cd ext/jellyfish/
autoreconf -i
./configure --prefix=$PWD/jellybin
make -j 4
make install
#Seccer installation
#echo "Compiling Seecer"
#cd ../..
#autoreconf -i
#./configure
#make
