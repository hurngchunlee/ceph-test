# Setting up Ceph datastore in OpenNebula

## References

- [OpenNebula instructions](http://docs.opennebula.org/4.10/administration/storage/ceph_ds.html)
- [Using libvirt with Ceph RBD](http://ceph.com/docs/master/rbd/libvirt/)

## Remarks

The above two sets of instructions are helpful. Following them can almost get things right,
except the following two things:

### configuring cephx authentication

The `virsh` commands for setting up security key and value should be done with `root`. Running
it just using `oneadmin` account will cause the error:

```
error: internal error rbd username 'libvirt' specified but secret not found
```

## Issues

- It seems that the VM image in ceph datastore has to be in 'raw' format.

    When the image is imported from OpenNebula marketplace, it is set to use format
    qcow2.  This may cause the VM initialization to fail with error:
    
    ```
    could not open disk image rbd:one/one-17-56-0:id=libvirt:key=xxxxxxxxxxxxxxxxxxxxxx==:auth_supported=cephx\;none:mon_host=dccn-c005\:6789\;dccn-c035\:6789: Invalid argument
    ```
    
