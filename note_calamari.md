# Ceph Management Interface (Calamari) Installation Note


## On salt-master node

- Open up firewall

    ```bash
    $ firewall-cmd --permanent --zone=<zone> --add-port=4505-4506/tcp
    $ firewall-cmd --reload
    ```