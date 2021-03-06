#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {projectId}"
    exit 1
fi

pid=$1
pdir=/project_cephfs/$pid
me=$(whoami)

echo -n "user uid: "
read uid
echo

## NOTE: what missing here is to check whether the current user is a manager
##       of the project.

if [ "$uid" != "" ]; then
    /usr/local/bin/cap_fowner /usr/bin/setfacl -R -x $uid $pdir
fi
