# Setting up Ceph cluster

## Architecture

- node organisation
    - admin: dccn-l018
    - mon: dccn-c005
    - osd: dccn-c035, dccn-c036
    
- filesystem on osd:
	- data: multiple disk aggregated into one BTRFS mount
	- journal: SSD

## Node preparation
- preparation on admin node (account: root)
	- add ceph repository 
	  
	  ```bash
	  $ /opt/cluster/sbin/ceph/01_add_ceph_yum_repo.sh
	  ```
	  
	- make sure `sudoers` are configured properly to include the specific SUDO configuration of ceph account. 
	- create ceph account
	
	    ```bash
	    $ /opt/cluster/sbin/ceph/02_create_manage_account.sh
	    ```
	    
	- install ntp packages
	
	    ```bash
	    $ /opt/cluster/sbin/ceph/03_install_ntp.sh
	    ```

- preparation on other nodes (account: root)
	-  create ceph account
	    
	    ```bash
	    $ /opt/cluster/sbin/ceph/02_create_manage_account.sh
	    ```
	    
	-  install ntp packages
	    
	    ```bash
	    $ /opt/cluster/sbin/ceph/03_install_ntp.sh
	    ```

- distribute SSH key for password-less login from admin node to other nodes (account: ceph)
	- logon to the admin node via ceph account 
	- run
	
	    ```bash 
	    $/opt/cluster/sbin/ceph/04_deploy_ceph_sshkey.sh [host1] {[host2] ...]}
	    ```
	    
	- add the following contents into  `$HOME/.ssh/config`
	
	    ```bash
        Host dccn-c005
            StrictHostKeyChecking no
            UserKnownHostsFile=/dev/null
            Hostname dccn-c005.dccn.nl 
            User ceph 
        Host dccn-c035 
            StrictHostKeyChecking no
            UserKnownHostsFile=/dev/null
            Hostname dccn-c035.dccn.nl 
            User ceph 
        Host dccn-c036 
            StrictHostKeyChecking no
            UserKnownHostsFile=/dev/null
            Hostname dccn-c036.dccn.nl 
            User ceph
	    ```
	  
	- change mode of `$HOME/.ssh/config`
	
	    ```bash
	    $ chmod 600 $HOME/.ssh/config
	    ```
	   
	- test if user ceph can login without password.
	  
## Cluster installation

- login to admin node (account: ceph)

- create directory for cluster profile's

    ```bash
    $ mkdir $HOME/dccn-ceph-cluster
    $ cd $HOME/dccn-ceph-cluster
    ```
    
- create new cluster profile, the first MON node needs to be given.

    ```bash
    $ ceph-deploy new dccn-c005
    ```
    
- 
	