#!/bin/bash
#

if [ $# -ne 1 ]; then
    echo "Usage: $0 {projectId}"
    exit 1
fi

pid=$1
pdir=/project_cephfs/$pid

mkdir $pdir && \
chown project.project_g $pdir && \
chmod 2770 $pdir && \
setfacl -d -m group::-- $pdir && \
setfacl -m group::-- $pdir

## add initial manager
echo -n "initial manager: "
read uid
echo
if [ "$uid" != "" ]; then
    setfacl -d -m $uid:rwx $pdir && \
    setfacl -m $uid:rwx $pdir
fi
