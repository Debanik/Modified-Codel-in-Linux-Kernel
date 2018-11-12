#!/bin/bash

#tcp_1up tcp_2up tcp_4up tcp_5up tcp_6up tcp_8up tcp_12up tcp_50up

#5 10 16 20 30 40 60 80 100 150 200 300 400 500 550
#5 10 16 10 20 30 50 70 90 130 180 280 380 480
#4 9 19 49 99 199 299 399 499


 	     sudo ethtool -K eno1 tso off
	     sudo ethtool -K eno1 gso off
#	     sudo ethtool -K eno1 lro off
	     sudo ethtool -K eno1 gro off
#	     sudo ethtool -K eno1 ufo off
	     sudo sysctl net.ipv4.tcp_ecn=0

 	     ssh root@192.168.1.1 sudo ethtool -K eno1 tso off
 	     ssh root@192.168.1.1 sudo ethtool -K eno1 gso off
#      	     ssh root@192.168.1.1 sudo ethtool -K eno1 lro off
 	     ssh root@192.168.1.1 sudo ethtool -K eno1 gro off
# 	     ssh root@192.168.1.1 sudo ethtool -K eno1 ufo off
	     ssh root@192.168.1.1 sudo sysctl net.ipv4.tcp_ecn=0

for tcp in cubic;
do
#for aqm in pfifo PIE MinstrelPIE;
for aqm in CoDel;
do
for test in tcp_5up; #Change the mumber of TCP Flows
do
   for rtt in 65;
	do
 	delay1=$(echo "(${rtt}+1)" | bc -l)
# 	delay2=$(echo "(${rtt}*20/100)" | bc -l)
  for vary in 15;
    do
	     echo ${tcp} |sudo tee /proc/sys/net/ipv4/tcp_congestion_control
#	     echo reno |sudo tee /proc/sys/net/ipv4/tcp_congestion_control

	     ssh root@192.168.50.2 sudo tc class add dev eno1 parent 1: classid 1:10 htb rate 10mbit ceil 10mbit
	     ssh root@192.168.1.1 echo ${tcp} |sudo tee /proc/sys/net/ipv4/tcp_congestion_control
#	     ssh root@192.168.1.1 echo reno |sudo tee /proc/sys/net/ipv4/tcp_congestion_control

	 #Host machine setup
#	 	sudo tc qdisc del dev eno1 root
#		sudo tc qdisc add dev eno1 root handle 1 htb
#		sudo tc class add dev eno1 parent 1: classid 1:10 htb rate 1000mbit ceil 1000mbit
#		if  [ "$delay" -lt 20 ] 
#		then
#		sudo tc qdisc add dev eno1 parent 1:10 handle 1100: netem limit 1000 delay 1ms
#		elif  [ "$delay" -lt 100 ] 
#		then
#		sudo tc qdisc add dev eno1 parent 1:10 handle 1100: netem limit 1000 delay 10ms
#		else
#		sudo tc qdisc add dev eno1 parent 1:10 handle 1100: netem limit 1000 delay ${delay}ms
#		fi

	#Router setup
		
		ssh root@192.168.50.2 sudo modprobe ifb
		ssh root@192.168.50.2 sudo ifconfig ifb0 down 
		ssh root@192.168.50.2 sudo ifconfig ifb0 up
		ssh root@192.168.50.2 sudo ifconfig ifb1 down 
		ssh root@192.168.50.2 sudo ifconfig ifb1 up 
		ssh root@192.168.50.2 sudo tc qdisc del dev ifb0 root
		ssh root@192.168.50.2 sudo tc qdisc del dev ifb1 root
		ssh root@192.168.50.2 sudo tc qdisc add dev ifb0 root handle 1 htb
		ssh root@192.168.50.2 sudo tc qdisc add dev ifb1 root handle 1 htb
		ssh root@192.168.50.2 sudo tc class add dev ifb0 parent 1: classid 1:10 htb rate 100mbit ceil 100mbit 
		ssh root@192.168.50.2 sudo tc class add dev ifb1 parent 1: classid 1:10 htb rate 10mbit ceil 10mbit
		if [ $aqm = "MinstrelPIE" ]
		then
		ssh root@192.168.50.2 sudo tc qdisc add dev ifb1 parent 1:10 handle 1100: pie limit ${vary} target 15ms tupdate 16ms minstrel ecn
		elif [ $aqm = "PIE" ]
		then
		ssh root@192.168.50.2 sudo tc qdisc add dev ifb1 parent 1:10 handle 1100: pie limit ${vary} target 15ms tupdate 16ms ecn		
		elif [ $aqm = "MADPIE" ]
		then
		ssh root@192.168.50.2 sudo tc qdisc add dev ifb1 parent 1:10 handle 1100: pie limit 200 target 15ms tupdate 16ms madpie
		elif [ $aqm = "CoDel" ]
		then
		ssh root@192.168.50.2 sudo tc qdisc add dev ifb1 parent 1:10 handle 1100: codel limit 200 ecn
		elif [ $aqm = "FQ" ]
		then
		ssh root@192.168.50.2 sudo tc qdisc add dev ifb1 parent 1:10 handle 1100: fq limit 200
		elif [ $aqm = "pfifo" ]
		then
		ssh root@192.168.50.2 sudo tc qdisc add dev ifb1 parent 1:10 handle 1100: pfifo limit ${vary}
		fi

# 		ssh root@192.168.50.2 sudo tc qdisc add dev ifb0 parent 1:10 handle 1100: netem limit 1000 delay 1ms 
#		ssh root@192.168.50.2 sudo tc qdisc add dev ifb1 parent 1:10 handle 1100: netem limit 1000 delay ${rtt}ms 
		ssh root@192.168.50.2 sudo tc filter add dev ifb0 protocol ip parent 1: handle 10 fw flowid 1:10
		ssh root@192.168.50.2 sudo tc filter add dev ifb1 protocol ip parent 1: handle 10 fw flowid 1:10

		ssh root@192.168.50.2 sudo tc qdisc del dev eno1 root
		ssh root@192.168.50.2 sudo tc qdisc del dev enp2s0 root
		ssh root@192.168.50.2 sudo tc qdisc add dev eno1 root handle 1 htb
		ssh root@192.168.50.2 sudo tc qdisc add dev enp2s0 root handle 1 htb
		ssh root@192.168.50.2 sudo tc class add dev eno1 parent 1: classid 1:10 htb rate 1000mbit ceil 1000mbit
		ssh root@192.168.50.2 sudo tc class add dev enp2s0 parent 1: classid 1:10 htb rate 100mbit ceil 100mbit	
 		ssh root@192.168.50.2 sudo tc qdisc add dev eno1 parent 1:10 handle 1100: netem limit 1000 delay 20ms 
		ssh root@192.168.50.2 sudo tc qdisc add dev enp2s0 parent 1:10 handle 1100: netem limit 1000 delay ${rtt}ms 

		
#		ssh root@192.168.50.2 sudo tc qdisc add dev enp2s0 parent 1:10 handle 1100: pfifo limit 1000
		
		ssh root@192.168.50.2 sudo tc filter add dev eno1 protocol ip parent 1: handle 10 fw flowid 1:10 action mirred egress redirect dev ifb0
		ssh root@192.168.50.2 sudo tc filter add dev enp2s0 protocol ip parent 1: handle 10 fw flowid 1:10 action mirred egress redirect dev ifb1
		ssh root@192.168.50.2 sudo iptables -t mangle -A POSTROUTING -s 192.168.2.2 -d 192.168.1.1 -j MARK --set-mark 10
#		echo $?
		ssh root@192.168.50.2 sudo iptables -t mangle -A POSTROUTING -s 192.168.1.1 -d 192.168.2.2 -j MARK --set-mark 10
#		echo $?
#		iperf -c 172.16.10.2 -u -b 10000000 -t 100
#		iperf -c 172.16.10.2		
#		./run-flent $test -p totals -l 100 -H 172.16.10.2 -t "$aqm-${rtt}"

#		./traffic_50s.sh & #For UDP flow testing
		./run-flent $test --test-parameter bandwidth=800M --test-parameter upload_stream=num_cpus --test-parameter download_streams=num_cpus --test-parameter qdisc_stats_hosts=root@192.168.50.2 --test-parameter qdisc_stats_interfaces=ifb1 --test-parameter control_host=192.168.1.1 -l 100 -H 192.168.1.1 -t "${aqm}-${vary}"

	done
done
done
done
done
