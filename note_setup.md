# Setting up Ceph cluster

## References

- [Ceph Quick Start](http://ceph.com/docs/master/start/)
- [Using BTRFS with multiple devices](https://btrfs.wiki.kernel.org/index.php/Using_Btrfs_with_Multiple_Devices)
- [PG calculator](http://ceph.com/pgcalc/)

    - In Ceph, the placement group (PG) is very essential for pool.
      It should be aligned carefully with the pool size (i.e. # replica of objects), 
      the number of OSDs and data size. Therefore this link.

## Architecture

- node organisation (initial)
    - admin: dccn-l018
    - mon: dccn-c005
    - mds: dccn-c005
    - osd: dccn-c035, dccn-c036
    
- node orgainsation (additional)
    - extra mon: dccn-c035
    - extra mds: dccn-c036 (for CephFS)
    
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
	    $/opt/cluster/sbin/ceph/04_deploy_ceph_sshkey.sh dccn-c005 dccn-c035 dccn-c036
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

### Initialisation

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
    
- __append__ the following lines in `ceph.conf`
    
    ```bash
    osd pool default size = 2

    [osd]
    osd journal size = 60000
    osd mkfs options btrfs = -f -d single
    ```
        
- install ceph packages on all nodes
    
    ```bash
    $ ceph-deploy install dccn-l018 dccn-c005 dccn-c035 dccn-c036
    ```
        
- initalise the cluster
    
    ```bash
    $ ceph-deploy mon create-initial
    ```
        
    This step generates keyrings to be shared amongst nodes in the cluster.
    At the moment, the MON service should be started on dccn-c005.
    
### Adding OSD's

- prepare OSD

    Here we assume on dccn-c035 and dccn-c036, `/dev/sdb` is the SSD, while 
    `/dev/sd[c-e]` are HDD's.
    
    The following commands will create an OSD on dccn-c035 and dccn-c036
    with data located on `/dev/sdc` and journal on `/dev/sdb`.  The size of journal
    will be `60 GB` as specified in the `ceph.conf` file.  Proper journal size 
    calculation follows [this recommendation](http://ceph.com/docs/master/rados/configuration/osd-config-ref/#journal-settings).

    ```bash
    $ ceph-deploy osd prepare --fs-type btrfs dccn-c035:/dev/sdc:/dev/sdb
    $ ceph-deploy osd prepare --fs-type btrfs dccn-c036:/dev/sdc:/dev/sdb
    ```

- activate OSD

    Firstly, login onto OSD nodes and check the directories created during the prepartion step above.
    Normally, it is under `/var/lib/ceph/osd` and called `ceph-N` where `N` is a sequencial number.
    
    If it's a clean installation, on dccn-c035, one should have `/var/lib/ceph/osd/ceph-0` and
    `/var/lib/ceph/osd/ceph-1` on dccn-c036

    ```bash
    $ ceph-deploy osd activate dccn-c035:/var/lib/ceph/osd/ceph-0
    $ ceph-deploy osd activate dccn-c036:/var/lib/ceph/osd/ceph-1
    ```

- adding more devices to BTRFS

    This step has nothing to do with Ceph; but under the management of BTRFS.
    BTRFS provides capability of adding/removing storage devices on the fly to a mounting point.
    We use this feature to add more disked into the Ceph cluster.
    
    Example of adding `/dev/sdd and /dev/sde` on dccn-c005
    
    - login dccn-c005 as root
        
    - run
        
        ```bash
        $ parted /dev/sdd mklabel gpt
        $ parted /dev/sdd mkpart primary 0% 100%
        $ btrfs device add -f /dev/sdd1 /var/lib/ceph/osd/ceph-0
        ```
            
    - repeat above commands for `/dev/sde`
        
    - rebalance data in BTRFS and mirror metadata (as in single disk mode, BTRFS use raid0 for metadata)
        
        ```bash
        $ btrfs balance start -mconvert=raid1 /var/lib/ceph/osd/ceph-0
        ```
        
    - after that, one should see three disks being utilized by a single BTFS file system
    
        ```bash
        $ btrfs fi show
        Label: none  uuid: 3bce839b-9683-49b6-ae5c-d0f009f8e8f4
	        Total devices 3 FS bytes used 1.07MiB
	        devid    1 size 1.09TiB used 40.00MiB path /dev/sdc1
	        devid    2 size 1.09TiB used 1.03GiB path /dev/sdd1
	        devid    3 size 1.09TiB used 1.00GiB path /dev/sde1

        Btrfs v3.16.2
        ```

## Finishing installation

- deploy the administrator keyring to all nodes

    ```bash
    $ ceph-deploy admin dccn-l018 dccn-c005 dccn-c035 dccn-c036
    ```

- no the management node, make sure the keyring of client.admin is readable for the `ceph` user 

    ```bash
    $ sudo chmod +r /etc/ceph/ceph.client.admin.keyring
    ```
    
## Check ceph cluster status

- health check

    ```bash
    $ ceph health
    HEALTH_OK
    ```
    
    If the health is not `OK`, resons of not being `OK` will be shown. If the
    reasoning is not clear, you may want to start from scratch.  In this case,
    follow the instructions below about __Purge Ceph Installation__
    to clean up everything and restart.
    
- cluster status

    ```bash
    $ ceph -s
    ```
    
- monitor cluster status (similar to `watch`)

    ```bash
    $ ceph -w
    ```
    
## Purge Ceph Installation

At the initial phase while still figuring out proper configuration of the Ceph cluster,
one may need repeat the installation steps few times.  For every iteration, it's more
convenient to start from scratch.  This prevent unexpected situation due to left-over
files for configurations, keyrings or ref. IDs.  The `ceph-deploy` command offers
a quick way to erase everything. The following steps show how to do it.  They should
be followed in a sequencial order.

- purge ceph installation

```bash
$ ceph-deploy purge dccn-l018 dccn-c005 dccn-c035 dccn-c036
```

This shuts down services and remove RPM packages from the nodes.

- purge ceph data

```bash
$ ceph-deploy purgedata dccn-l018 dccn-c005 dccn-c035 dccn-c036
```

This will remove entire directory of `/var/lib/ceph`, so data on OSD will be gone.

- forget all keys

```bash
$ ceph-deploy forgetkeys
```

This clean up all keyrings and `ceph.conf` file within the cluster profile folder.

## Adding extra services on nodes

### Adding Monitor nodes

According to the document, the `ceph-deploy` offers an simple command to add new MON to the cluster.
However, I encounter the issue with it, as some command executed remotely to provision the MON service
gets stuck.  It causes connection timeout, but nevertheless, the deployment continues to add MON into the cluster.

To clean up the mass leftover by the timeout, I figured out that one should login to the node on which
the new MON is deployed.  Kill relevant processes (very likely the one with command `ceph-mon`), and restart
the ceph daemon.  After that, the service seems to be running fine.

__TODO:__ need to try the manual step of adding new MON in the future.

### Adding MDS nodes

MDS (metadata system) node is required for running CephFS, a filesystem interface to Ceph cluster.

```bash
$ ceph-deploy mds create dccn-c005
```