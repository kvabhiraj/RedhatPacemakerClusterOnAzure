# Redhat Pacemaker active-passive HA cluster on Azure (RHEL10 2-node Master-slave cluster with DRBD - LAB environment) - IAC

 A high-availability setup managed by Pacemaker where service instances run in hierarchical roles: Master (primary/active) and Slave (secondary/standby). 
 
**How it Works :** \
Master Role: Handles active operations, live data updates, or primary traffic processing. \
Slave Role: Keeps a synchronised copy or stands ready to take over paired with storage replication tools like DRBD. \
Promotion/Demotion: Pacemaker monitors node health and automatically promotes a slave to master if the active master fails. 

**DRBD** (Distributed Replicated Block Device) is a software-based, open-source replication system for Linux. 

**How DRBD Works :** \
Kernel Level: It runs inside the Linux kernel as a virtual block device driver, sitting below file systems and above physical storage. \
Transparent Copy: When data is written to the primary server, DRBD saves it locally and sends a copy over the network to the secondary server at the same time. \
Replication Modes: It supports synchronous (Protocol C) for safety, semi-synchronous (Protocol B), and asynchronous (Protocol A) for speed 


Pre-requisites
============================================================== 

To be continued ------
