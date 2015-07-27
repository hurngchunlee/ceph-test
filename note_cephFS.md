# CephFS setup

## Ceph MDS (metadata server for CephFS)
 - dccn-c005
 - dccn-c036

## Clients
 - mentat004
 - dccn-c029 - dccn-c034
 - dccn-c350 - dccn-c354
 
## CephFS creation

- deploy MDS from the management node

```bash
$ ceph mds create dccn-c005
```