# CephFS setup

## Ceph management node
 - dccn-l018

## Ceph MDS (metadata server for CephFS)
 - dccn-c005
 - dccn-c036

## CephFS Clients
 - mentat004
 - dccn-c029 - dccn-c034
 - dccn-c350 - dccn-c354
 
## CephFS creation

- create Ceph pools for CephFS, e.g. `cephfs_data` for data, and `cephfs_metadata` for metadata,
  with `pg_num` and `pgp_num` equal to `4`.

    ```bash
    $ ceph osd pool create cephfs_data 4
    $ ceph osd pool create cephfs_metadata 4
    ```
    
- create new CephFS on top of the pools

    ```bash
    $ ceph fs new cephfs cephfs_metadata cephfs_data
    ```
    
- check the CephFS

    ```bash
    $ ceph fs ls
    name: cephfs, metadata pool: cephfs_metadata, data pools: [cephfs_data ]
    ```
    
- deploy MDS from the management node

    ```bash
    $ ceph-deploy mds create dccn-c005
    $ ceph-deploy mds create dccn-c036
    ```

- check MDS status

    ```bash
    $ ceph mds stat
    e43: 1/1/1 up {0=dccn-c005=up:active}, 1 up:standby
    ```
    
    Just for fun, one could test the failover by manually failing the active MDS (e.g. to fail the one with index 0):
    
    ```bash
    $ ceph mds fail 0
    failed mds.0
    ```
    
    Now check the MDS status again, you will see another MDS takes over
    
    ```bash
    $ ceph mds stat
    $ e51: 1/1/1 up {0=dccn-c036=up:active}, 1 up:standby
    ```
    
## CephFS client setup

- create `ceph` management account on the client nodes

    ```bash
    $ /opt/cluster/sbin/ceph/02_create_manage_account.sh
    ```
    
    __Note__: follow the instruction to set `sudo` and `sshd` for the ceph user.
    
- distribute SSH public key from the management node to client nodes. 
  The following instructions use `mentat004` as an example, repeat it for all client nodes.

    - login to management node with `ceph` account
    
    - copy SSH public key to client nodes
    
        ```bash
        $ ssh-copy-id ceph@mentat004
        ```
    
    - for the convenience, one could make the following configuration in `$HOME/.ssh/config`
    
        ```bash
        Host mentat004
        StrictHostKeyChecking no
        UserKnownHostsFile=/dev/null
        User ceph
        Host mentat004.dccn.nl
        StrictHostKeyChecking no
        UserKnownHostsFile=/dev/null
        User ceph
        ```
        
    - test for passwordless login to the client node
    
        ```bash
        $ ssh mentat004
        ```
        
        The `ceph` user should login to `mentat004` without password.
        
- deploy Ceph packages to client node

    ```bash
    $ ceph-deploy install mentat004
    ```
    
- make a `cephx` user specific for mounting CephFS

    ```bash
    $ ceph auth get-or-create client.cephfs mds 'allow' mon 'allow *' osd 'allow * pool=cephfs_data, allow * pool=cephfs_metadata' -o ceph.client.cephfs.keyring
    ```
    
    The above command adds a cephx user `client.cephfs`, retrieve and store the secret key of the user in `ceph.client.cephfs.keyring`.
    
- deploy the secret key of `client.cephfs` to client node

    ```bash
    $ /mnt/software/cluster/sbin/ceph/05_deploy_cephfs_secret.sh `grep 'key' ceph.client.cephfs.keyring | awk '{print $NF}'` mentat004
    ```
    
- make mounting point (e.g. /mnt/cephfs) and mount CephFS

    ```bash
    $ ssh -tt ceph@mentat004 'sudo mkdir /mnt/cephfs'
    $ ssh -tt ceph@mentat004 'sudo mount -t ceph dccn-c005:/ /mnt/cephfs -o name=cephfs,secretfile=/etc/ceph/cephfs.secret'
    ```
    
    where `dccn-c005` is one of the __MON__ (yes, it's __MON__, not __MDS__) in the cluster.
    
## Remarks

- ACL doesn't seem to be supported in current kernel.  According to reports on internet, it will be available in kernel 3.14 onwards ... The ACL it supports is in the POSIX-style.

- first performance test using `dd` to put data into CephFS, with comparison to local disk.

    - Test host: `mentat004`
    
    - Test command
    
        ```bash
        $ dd if=/dev/zero of=/mnt/cephfs/test/zero.$$ bs=1024 count=<N>
        ```
        
        where `<N>` is listed in the result table below.
        
    - Test result

    | size    |  <N>       | CephFS    | Local disk (ext4) |
    | -------:| ----------:|----------:| -----------------:|
    | 1 KB    |  1         | 22.7 KB/s | 5.6 MB/s          |
    | 4 KB    |  4         | 3.7 MB/s  | 32.9 MB/s         |
    | 100 KB  |  100       | 33 MB/s   | 140 MB/s          |
    | 1 MB    |  1024      | 178 MB/s  | 182 MB/s          |
    | 4 MB    |  4096      | 283 MB/s  | 196 MB/s          |
    | 16 MB   |  16384     | 345 MB/s  | 252 MB/s          |
    | 512 MB  |  524288    | 795 MB/s  | 474 MB/s          |
    | 1 GB    |  1048576   | 837 MB/s  | 499 MB/s          |
    | 2 GB    |  2097152   | 857 MB/s  | 500 MB/s          |
    | 4 GB    |  4194304   | 869 MB/s  | 503 MB/s          |