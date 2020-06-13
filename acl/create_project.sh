#!/bin/bash

# This script setup initial project permission and acl so that the following
# files/sub-directories created within it will follow.

[ $# -lt 1 ] && echo "Usage: $0 {pid}" >&2 && exit 1
pid=$1

# use PROJECT_ROOT to specify the directory in which projects are
# organized.  For example, the directory for project 3055000.01
# will `$PROJECT_ROOT/3055000.01`.
[ ! -z PROJECT_ROOT ] && PROJECT_ROOT=/cephfs/data/project

# The PROJECT_ROOT directory should exist.
[ ! -d $PROJECT_ROOT ] && echo "directory not found: $PROJECT_ROOT" >&2 && exit 1

ppath=$PROJECT_ROOT/$pid

[ ! -d $ppath ] && mkdir -p $ppath

# change project directory owned by project and project_g group.
chown project:project_g $ppath

# 1. set project directory mode to rwxrwx--- (770)
#    the reason the group permission is `rwx` is because of the ACL mask.
# 2. enable the `setgid` bit on the permission so that new files created on
#    linux will be owned by the `project_g`. This circumvent the issue that
#    the acl mask is always synced with group permission; and we need the
#    acl mask to be `rwx` (see below).
# 3. set mask to "rwx" for project directory and inherit it to subdirectories.
#    mask "rwx" means no acl bit is filtered.
# 4. remove entire group access as default.

chmod 2770 $ppath && 
  setfacl -n -m m::rwx $ppath && setfacl -n -d -m m::rwx $ppath &&
  setfacl -m group::-- $ppath && setfacl -d -m group::-- $ppath

## add initial manager
echo -n "comma-separated list of initial manage(s): "
read uids
echo
if [ "$uids" != "" ]; then
    for uid in $(echo $uids | sed 's/,/ /g'); do
        setfacl -d -m $uid:rwx $ppath && \
        setfacl -m $uid:rwx $ppath
    done
fi
