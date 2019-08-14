#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {projectId}"
    exit 1
fi

pid=$1
me=$(whoami)

smbcacls //dccn-ceph003/project_cephfs_k /$pid -U"DCCN\\${me}"
