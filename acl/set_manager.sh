#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {projectId}"
    exit 1
fi

pid=$1
pdir=/project_cephfs/$pid
me=$(whoami)

echo -n "manager uid: "
read uid
echo

## NOTE: what missing here is to check whether the current user is a manager
##       of the project.

if [ "$uid" != "" ]; then
    /usr/local/bin/cap_fowner /usr/bin/setfacl -R -d -m $uid:rwx $pdir && \
    /usr/local/bin/cap_fowner /usr/bin/setfacl -R -m $uid:rwx $pdir
    #smbcacls //dccn-ceph003/project_cephfs_k /$pid -M "ACL:DCCN\\${uid}:ALLOWED/3/FULL" -U"DCCN\\${me}"
    #smbcacls //dccn-ceph003/project_cephfs_k /$pid -M "ACL:DCCN\\${uid}:ALLOWED/3/FULL" -U"DCCN\\${me}" -I allow --propagate-inheritance
fi
