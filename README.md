# Modified-CoDel-in-Linux-Kernel

#### Implementation and Evaluation of a modified version of the Controlled Delay Active Queue Management algorithm in Linux Kernel
###### Course Code: CS738
###### Assignment: #FP4

#### Overview:
With the existing version of **Controlled Delay Active Queue Management** algorithm [2] shown to be *inefficient* in case of UDP flows as well as the *proposed modifications* [1], we implement this **Modified Controlled Delay Active Queue Management** algorithm with the **_interval_** knob set to **30ms** , remove the square root over the count variable and a **modified CoDel Control Law** in the Linux Kernel with the help of pre-existing CoDel kernel code [3] and testing this modified AQM algorithm from a Linux machine to analyze and evaluate the results.

#### References

[1] https://ieeexplore.ieee.org/abstract/document/7947857/ 
[2] https://tools.ietf.org/html/rfc8289 
[3] https://elixir.bootlin.com/linux/latest/source/net/sched/sch_codel.c 
