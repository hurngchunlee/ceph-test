# Ceph Management Interface (Calamari) Installation Note

## References

- [CEPH CALAMARI : THE SURVIVAL GUIDE](https://ceph.com/category/calamari/)

    Follow the guide thoroughly, it's pretty much complete.  This note is to add
    points to complement this survival guide.

## On salt-master node

If the machine running calamari-server has firewall in place, extra tcp ports need
to be opened to allow salt clients (running on ceph nodes) to communicate with the server.

- Open up firewall

    ```bash
    $ firewall-cmd --permanent --zone=<zone> --add-port=4505-4506/tcp
    $ firewall-cmd --reload
    ```