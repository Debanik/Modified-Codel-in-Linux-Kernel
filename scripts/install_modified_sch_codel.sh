#!/bin/bash

SCRIPT_LOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HEADER_LOCATION=/lib/modules/4.15.0-38-generic/build/include/uapi/linux
MODULE_LOCATION=/lib/modules/4.15.0-38-generic/build/include/net

cd ${SCRIPT_LOCATION}/..

mkdir tmp

cp src/sch_codel.c tmp
cp src/Makefile tmp

cd tmp

sudo mv ${HEADER_LOCATION}/pkt_sched.h ${HEADER_LOCATION}/pkt_sched_backup.h
sudo cp ../src/pkt_sched.h ${HEADER_LOCATION}

sudo mv ${MODULE_LOCATION}/codel.h ${MODULE_LOCATION}/codel_backup.h
sudo cp ../src/codel.h ${MODULE_LOCATION}

sudo mv ${MODULE_LOCATION}/codel_impl.h ${MODULE_LOCATION}/codel_impl_backup.h
sudo cp ../src/codel_impl.h ${MODULE_LOCATION}

make

sudo rm ${HEADER_LOCATION}/pkt_sched.h
sudo mv ${HEADER_LOCATION}/pkt_sched_backup.h ${HEADER_LOCATION}/pkt_sched.h

sudo rm ${MODULE_LOCATION}/codel.h
sudo mv ${MODULE_LOCATION}/codel_backup.h ${MODULE_LOCATION}/codel.h

sudo rm ${MODULE_LOCATION}/codel_impl.h
sudo mv ${MODULE_LOCATION}/codel_impl_backup.h ${MODULE_LOCATION}/codel_impl.h

cd ..

sudo rm ${MODULE_LOCATION}/sch_codel.ko
sudo cp tmp/sch_codel.ko ${MODULE_LOCATION}

rm -r tmp

lsmod | grep sch_codel >/dev/null

if [ $? -eq 0 ]
then
    sudo rmmod sch_codel 2>/dev/null

    if [ $? -ne 0 ]
    then
        for i in $(ls /sys/class/net)
        do
            sudo tc qdisc del dev ${i} root 2>/dev/null
        done

        sudo rmmod sch_codel
    fi
fi

sudo modprobe sch_codel
