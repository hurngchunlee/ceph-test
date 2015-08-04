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
    
### Services on Ceph nodes (Salt-minion and Diamond)

```bash
$ cp /etc/diamond/diamond.conf.example /etc/diamond/diamond.conf

$ cat /etc/salt/minion
master: ontest003.dccn.nl

$ service salt-minion restart
$ service diamond restart
```

On OSD nodes, enable OSD status report

```bash
$ cat /etc/diamond/collectors/CephCollector.conf | grep osd_stats
osd_stats_enabled = True
```

### Services on Calamari server

```bash
$ cp /etc/diamond/diamond.conf.example /etc/diamond/diamond.conf

$ service salt-server restart
$ service diamond restart
```

There are also services controlled by `supervisor`:

```bash
$ supervisorctl status
carbon-cache                     STOPPED    Aug 03 10:28 PM
cthulhu                          STOPPED    Aug 03 10:28 PM
```

```bash
$ supervisorctl start all
cthulhu: started
carbon-cache: started
```

## Known Issues

- [Salt issue 24613](https://github.com/saltstack/salt/issues/24613)

    This issue causes 500 Server Error and the OSD map info not reported properly.