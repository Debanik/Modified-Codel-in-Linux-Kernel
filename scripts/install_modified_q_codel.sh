#!/bin/bash

sudo apt-get install libmnl-dev

SCRIPT_LOCATION="$(pwd)"

cd ${SCRIPT_LOCATION}/../pkg #go to pkg inside parent directory
echo $(pwd)
tar -xf iproute2-4.15.0.tar.xz  #extract iproute

rm iproute2-4.15.0/tc/q_codel.c
cp ../src/iproute/q_codel.c iproute2-4.15.0/tc
rm iproute2-4.15.0/include/uapi/linux/pkt_sched.h
cp ../src/iproute/pkt_sched.h iproute2-4.15.0/include/uapi/linux

cd iproute2-4.15.0

./configure
make
sudo make install -j 4

cd ..

rm -r iproute2-4.15.0
