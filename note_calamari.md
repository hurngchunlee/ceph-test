# Ceph Management Interface (Calamari) Installation Note

## References

- [CEPH CALAMARI : THE SURVIVAL GUIDE](https://ceph.com/category/calamari/)

    Follow the guide thoroughly, it's pretty much complete.  This note is to add
    points to complement this survival guide.
    
## Building Calamari service package

## Building Calamari client package

## Installation

### Using the repository tarball generated from the build

__Note__: the salt-master RPM is only available if EPEL repo for CentOS is enabled.
Hereafter is an example for enabling EPEL for CentOS7.

```bash
$ wget https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
$ sudo yum install epel-release-7-5.noarch.rpm
```

### Firewall on calamari-server 

If the machine running calamari-server has firewall in place, extra tcp ports need
to be opened to allow salt clients (running on ceph nodes) to communicate with the server.

- Open up firewall

    ```bash
    $ firewall-cmd --permanent --zone=public --add-port=4505-4506/tcp
    $ firewall-cmd --permanent --zone=public --add-port=2003/tcp
    $ firewall-cmd --permanent --zone=public --add-port=2004/tcp
    $ firewall-cmd --permanent --zone=public --add-port=80/tcp
    $ firewall-cmd --reload
    ```