# Module description

This module implements roles, ie very **top level** classes.

List of roles provided:

* [The role `generic`](README-generic.md)
* The role `generic_nullclient`. The only difference with
  the role `generic` is that the installation of a smtp
  null client is added (see the README of the `generic`
  role for more details).
* [The role `puppetserver`](README-puppetserver.md)
* The role `puppetforge` which has no parameter.
* The role `mcomiddleware` which has no parameter.
* The role `mcomiddleforge` which is the addition of the
  roles `mcomiddleware` and `puppetforge`
* [The role `pxeserver`](README-pxeserver.md)
* The role `puppetrouter` which has no parameter. It defines
  the addition of roles `puppetserver` and `pxeserver`. See
  the code to have more explanations.
* The role `ceph` which has no parameter.
* The role `mysqlnode` which has no parameter.
* [The role `moobotnode`](README-moobotnode.md)
* The role `gitlab` which has no parameter.
* The role `shadowldap` which has no parameter (TODO: not finished).
* The role `wproxyeleapoc` with only one parameter `rsyslog_allow_udp_reception`
  to retrieve haproxy logs from moolb.
* The role `proxmox` which has no parameter.
* The role `httpproxy` which has no parameter.
* [The role `confkeeper`](README-confkeeper.md)

If a role has no parameter, there is no specific README and
no detail. In this case, the code is the documentation.
Furthermore, if a role has a `with_generic` parameter, it's
not mentioned here.




# Warning about the role httpproxy

Generally, the server which has this role will be its own
APT proxy. But in this case, a run puppet will not work because:

    1. the server will be its own APT proxy
    2. but the APT proxy will be not yet installed by Puppet.

In brief, a problem of chicken and egg. So, the first time
before to launch a puppet run, you have to install
apt-cache-ng manually:

```sh
apt-get install apt-cacher-ng
```

After that, the first puppet run will probably have some
errors because the server will be its own keyserver but the
keyserver service will be not yet installed. But normally
this point is not blocking and you should have a puppet run
perfectly clean the second time. Only the absence of
apt-cacher-ng at the first time blocks completely the Puppet
installations.





