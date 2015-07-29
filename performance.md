# Note on Ceph performance

## Reference
- [SSD sequential write test](http://www.sebastien-han.fr/blog/2014/10/10/ceph-how-to-test-if-your-ssd-is-suitable-as-a-journal-device/)
    - note that the `hdparm` should be replaced with `sdparm` for SCSI drives.
    
- [Intel SSDSC2BB12 speed](http://www.intel.com/content/www/us/en/solid-state-drives/solid-state-drives-dc-s3500-series.html), note the sequencial write speed of 135 MB/s.
 
## System configuration
 
- MON: dccn-c005 (1Gb nic)
    
- OSD hosts:
    
    - dccn-c035 (10Gb nic)
        - osd.[0-2]: btrfs, 1.2 TB (SEAGATE ST1200MM0088), journal on partition of a shared SSD (Intel SSDSC2BB12).
            
    - dccn-c036 (10Gb nic)
        - osd.[3-6]: btrfs, 1.2 TB (SEAGATE ST1200MM0088), journal on partition of a shared SSD (Intel SSDSC2BB12).

## Ceph configuration (ceph.conf)

```bash
[global]
auth_service_required = cephx
filestore_xattr_use_omap = true
auth_client_required = cephx
auth_cluster_required = cephx
mon_host = 131.174.44.162
mon_initial_members = dccn-c005
fsid = e1cc194b-5acf-4b20-a014-819a53f443b0

osd pool default size = 2
filestore max sync interval = 10
filestore journal writeahead = false

[osd]
osd journal size = 16384
osd mkfs options btrfs = -f -d single
osd mkfs options xfs = -f -i size=2048
osd mount options xfs = rw,noatime,inode64,logbsize=256k,delaylog
osd op threads = 16
```

## Results

# rados benchmark

- writing

    ```bash
    $ rados -p rbd bench 30 write --no-cleanup
    ---- >8 -----
    Total writes made:      1070
    Write size:             4194304
    Bandwidth (MB/sec):     140.801 

    Stddev Bandwidth:       27.6258
    Max bandwidth (MB/sec): 160
    Min bandwidth (MB/sec): 0
    Average Latency:        0.454223
    Stddev Latency:         0.0790595
    Max latency:            0.747938
    Min latency:            0.0756266
    ```
- sequencial read

    ```bash
    $ rados -p rbd bench 30 seq -no-cleanup
    ----- >8 -----
    Total reads made:     1021
    Read size:            4194304
    Bandwidth (MB/sec):    1114.696 

    Average Latency:       0.0572172
    Max latency:           0.415066
    Min latency:           0.00980005
    ```
    
- random read

    ```bash
    $ rados -p rbd bench 30 rand --no-cleanup
    Total reads made:     8428
    Read size:            4194304
    Bandwidth (MB/sec):    1121.071 

    Average Latency:       0.057057
    Max latency:           0.419418
    Min latency:           0.00965817
    ```
    
- cleanup

    ```bash
    $ rados -p rdb cleanup
    ```