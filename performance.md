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