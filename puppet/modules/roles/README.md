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
* The role `wproxyeleapoc` which has no parameter.
* The role `proxmox` which has no parameter.

If a role has no parameter, there is no specific README and
no detail. In this case, the code is the documentation.
Furthermore, if a role has a `with_generic` parameter, it's
not mentioned here.


