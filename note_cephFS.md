# CephFS setup

## Ceph MDS (metadata server for CephFS)
 - dccn-c005
 - dccn-c036

## Clients
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

- 