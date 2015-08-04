# Ceph Management Interface (Calamari) Installation Note

## References

- [CEPH CALAMARI : THE SURVIVAL GUIDE](https://ceph.com/category/calamari/)

    Follow the guide thoroughly, it's pretty much complete.  This note is to add
    points to complement this survival guide.
    
## Binary packages for CentOS6 and CentOS7

RPM packages prebuilt for CentOS6 and CentOS7 systems are available within the directory
`calamari_build` within this repository.
    
## Building Calamari service package

- Get source codes of calamari and diamond (calamari branch)

    ```bash
    $ mkdir /tmp/calamari-repo
    $ cd /tmp/calamari-repo
    $ git clone https://github.com/ceph/calamari.git
    $ git clone https://github.com/ceph/Diamond.git --branch=calamari
    ```
    
- Boot up VM w/ targeting system via vagrant

    __Note__: at this stage, one needs [vagrant](https://www.vagrantup.com) and
    a VM driver (the simplest one is [VirtualBox](https://www.virtualbox.org)) installed in the system.
    
    ```bash
    $ cd calamari/vagrant/centos7-build
    $ vagrant up
    ```
    
    > For some reason, the salt-minion configuration file is not copied over via SSH.  You will see
    > errors regarding to this at the end of the `vagrant up` command.  We will modify it manually later.
    
    Firstly connect to the VM via
    
    ```bash
    $ vagrant ssh
    ```
    
    Modify `/etc/salt/minion` with the following content
    
    ```bash
    master: localhost
    file_client: local
    ```
    
- Build calamari-server RPMs

    Do it within the VM.  Run the following command:
    
    ```bash
    $ sudo salt-call state.highstate
    ```
    
    If everything runs fine, you will get the following packages on the host's `/tmp/calamari-repo` directory:
    
    ```
    calamari-repo-el7.tar.gz
    calamari-server-1.3.0.1-74_g57e4860.el7.x86_64.rpm
    calamari-server-debuginfo-1.3.0.1-74_g57e4860.el7.x86_64.rpm
    diamond-3.4.67-0.noarch.rpm
    diamond-3.4.67-0.src.rpm
    ```
    
    > Build in the `centos6-build` has a problematic dependency file `salt/roots/build_deps.sls`.
    > In centos6, there does not exist package called `selinux-policy-core`.  Remove this line and
    > replace with `selinux-policy`, `selinux-policy-doc` and `policycoreutils`.

## Building Calamari client package

- Get source code from github

    ```bash
    $ cd /tmp/calamari-repo
    $ git clone https://github.com/ceph/romana.git
    $ cd romana
    ```
    
    > The calamari-client is recently renamed to romana. Therefore we check out the latest
    > version via the romana repository.
    
- Boot up VM w/ Ubuntu precise via vagrant

    > Build within Ubuntu precise is needed as it's the most reliable procedure. 
    > It will build the `deb` package together with a software tarball that can be
    > used in other systems (e.g. CentOS).
    
    Before we boot up the VM, the following steps should be taken to overcome
    [this issue](https://github.com/saltstack/salt-bootstrap/issues/637).
    
    1. replace the `URL` in `vagrant/urllib-bootstrap-salt.sh` with
    
        ```bash
        https://raw.githubusercontent.com/saltstack/salt-bootstrap/develop/bootstrap-salt.sh
        ```
        
    2. add the following line in `vagrant/precise-build/Vagrantfile`
    
        ```bash
        salt.bootstrap_options = "-P"
        ```
        
    Boot up the VM with
    
    ```bash
    $ cd vagrant/precise-build
    $ vagrant up
    ```
    
    Login to the VM with
    
    ```bash
    $ vagrant ssh
    ```
    
    The same as building `calamari-server`, here we also need to configure `/etc/salt/minion` manaully.
    
- Build calamari-server (romana) packages

    Install dependencies:
    
    ```bash
    $ sudo apt-get install ruby1.9.1 ruby1.9.1-dev python-software-properties g++ make git debhelper build-essential devscripts

    $ sudo apt-add-repository http://ppa.launchpad.net/chris-lea/node.js/ubuntu
    $ sudo apt-get update
    $ sudo apt-get install nodejs
    $ sudo npm install -g bower@1.3.8
    $ sudo npm install -g grunt-cli
    $ sudo gem install compass
    ```
    
    Build the packages
    
    ```bash
    $ sudo salt-call state.highstate
    ```
    
    Upon success, the following packages will be presented in host's `/tmp/calamari-repo`
    
    ```bash
    calamari-clients_1.2.2-32-g931ee58_all.deb
    calamari-clients-build-output.tar.gz
    ```
    
## Installation

### Calamari server

The server has to run on a machine on which the Ceph client can operate.  For example, one should be
able to do `ceph -s` on this machine.  From the ceph management node, one could use the following
commands to deploy a ceph client (`ontest003` in this example):

```bash
$ ceph-deploy install ontest003
$ ceph-deploy admin ontest003
```

### Using the repository tarball generated from the build

- Install salt-master RPM from the EPEL repo. Hereafter is an example for enabling EPEL for CentOS7.

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
    A workaround is to downgrade salt to 2014 version on the calamari server.
    
    ```bash
    $ rpm -Uvh --oldpackage salt-2014.7.5-1.el7.noarch.rpm  salt-minion-2014.7.5-1.el7.noarch.rpm salt-master-2014.7.5-1.el7.noarch.rpm
    ```