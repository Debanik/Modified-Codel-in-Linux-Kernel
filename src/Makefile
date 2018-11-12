obj-m += sch_codel.o

all:
	make -C /lib/modules/4.15.0-38-generic/build M=$(PWD) modules

clean:
	make -C /lib/modules/4.15.0-38-generic/build M=$(PWD) clean
