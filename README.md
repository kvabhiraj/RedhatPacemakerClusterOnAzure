# Redhat Pacemaker active-passive HA cluster on Azure. (RHEL8, 2-node master-slave cluster with DRBD - LAB environment) - IAC

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

1. Install and configure Azure CLI in your system (Linux / Mac) \
   a. Install Azure CLI \
       [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
   
   b. Authenticate Azure using azure CLI \
       [https://docs.aws.amazon.com/cli/v1/userguide/cli-authentication-user.html](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest)

2. Install and configure GIT \
   a. Install GIT \
       https://github.com/git-guides/install-git \
   b. Setup GIT \
       https://docs.github.com/en/get-started/git-basics/set-up-git 
   
3. Install and configure terraform \
   a. Install Terraform \
       https://developer.hashicorp.com/terraform/install

Clone the GIT repository 
==============================================================

01. Redhat pacemaker high-availability cluster ( Master-Slave ) # Baseline \
    git clone -b main https://github.com/kvabhiraj/RedhatPacemakerClusterOnAzure.git

Initiate IAC to deploy Azure VM
==============================================================

1. Login to azure cli
    az login
    
2. Update "Resource group" in variable.tf file in the below given block \
    variable "RG" {
      type        = string
      description = "Resource Group Name"
      default     = "<Resource group taken from azure portal>" # <=========== Update here
}
    
3. Run bellow given terraform commands \
    terraform init \
    terraform plan \
    terraform apply -auto-approve 

   # To be continued .......
