echo "Sleeping for 25secs";
sleep 30;
echo "Sending UDP packets";
iperf -u -c 192.168.1.1 -t 50 -b 10M;
echo "DONE";
