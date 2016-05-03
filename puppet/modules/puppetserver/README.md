# Module description

This module allows to install a Puppet 4 server.




# Usage

Here is an example:

```puppet
$pubkeys = {
  'root@srv-1' => { 'type' => 'ssh-rsa', 'keyvalue' => 'AAA...', },
  'root@srv-2' => { 'type' => 'ssh-rsa', 'keyvalue' => 'AAA...', },
}

class { '::puppetserver::params':
  puppet_memory          => '4g',
  puppetdb_memory        => '1g',
  profile                => 'autonomous',
  modules_repository     => 'http://puppetforge.domain.tld',
  strict_variables       => true,
  puppetdb_name          => 'puppet',
  puppetdb_user          => 'puppet',
  puppetdb_pwd           => '123456',
  puppetdb_certwhitelist => [ $::fqdn, "puppet2.${::domain}" ],
  modules_versions       => {
                              'author-modA' => '1.2.1',
                              'author-modB' => '0.4.0',
                            },
  max_groups             => 3,
  groups_from_master     => [],
  mcrypt_pwd             => 'abcdef',
  authorized_backup_keys => $pubkeys,
}

include '::puppetserver'
```




# Parameters

The `puppet_memory` and `puppetdb_memory` parameters set the
RAM available for the JVM of the puppetserver and the RAM
available for the JVM of the puppetdb server. The default
value of these parameters is `'1g'` (ie 1GB). Another
possible value is `'512m'` for instance (ie 512MB).

The `profile` parameter is important. The two possible
values for this parameter are `'client'` or `'autonomous'`:

* If the value is `'autonomous'`, the puppetserver will
be the Puppet CA and its puppet agent will become puppet
client of itself. The puppetdb service will be installed too.

* If the value is `'client'`, the puppet agent will be and
will stay the client of its current puppetserver which will
stay the puppet CA too. Then, the puppetdb service will not
be installed on this host (and the parameters related to
Puppetdb will be ignored).

The `profile` parameter has no default value. You must
define its value yourself explicitly.

The `modules_repository` parameter is the url address of a
Puppet forge server requested by the puppetserver. The
default value of this parameter is `undef`. In this case the
puppetserver will request directly the official Puppetlabs
forge. If you set this parameter, you must give a complete
url: for instance `http://mypuppetforge.domain.tld:8080`
(with the protocol, ie http or https, and the port if
different of 80).

The `strict_variables` parameter is the value of the option
`strict_variables` in the `puppet.conf` file. The possible
values are `true`, `false` and `undef` (the default). When
the value is `undef`, the option is just not present in the
file `puppet.conf` and, in this case, the default value from
Puppet software is set.

The `puppetdb_name`, `puppetdb_user` and `puppetdb_pwd`
parameters set the name of the PostgreSQL database, the
PostgreSQL user account and its password used by the
puppetdb Web server. The default value of the
`puppetdb_name` and `puppetdb_user` parameters is
`'puppet'`. The `puppetdb_pwd` parameter has no default
value and you must set this parameter explicitly. Of course,
these parameters are only needed if the profile of the
server is `autonomous`. In the case of a `client`
puppetserver, these parameters are completely ignored
(and `puppetdb_pwd` can be let unset).

The `puppetdb_certwhitelist` parameter allows to set (or
not) the `certificate-whitelist` feature of puppetdb. The
parameter must be an array of fqdns and only the nodes
specified in this array can request the puppetdb server. The
specific value `[]` (an empty array) is possible. In this
case, the feature `certificate-whitelist` is not set at all
and **all** puppet nodes can request the puppetdb server.
The default value of this parameter is `[ $::fqdn ]`, ie
only the puppetserver can request the puppetdb server.

The `modules_versions` is a hash like above to force the
installation of specific modules with a specific version
during the execution of the script `install-modules.puppet`.
The default value of this parameter is `{}` (an empty hash)
which means that there are no pinning of a specific version.
Be careful, the version are pinned when a module is
installed via the script `install-modules.puppet`, but this
pinning is completely ignored by the classical command
`puppet module install`.

The `max_groups` parameter is an integer greater or equal to
1. It's the maximum number of groups to which a node belongs
in the data hierarchy (in the file `hiera.yaml`. The default
value of this parameter is `5`.

The `groups_from_master` parameter is an array of non-empty
strings (but the array can be empty). The default value of
this parameter is `[]` (ie an empty array). This parameter
is only useful for a `client` puppetserver. This parameter
will be completely ignored for a `autonomous` puppetserver.
For a `client` puppetserver, this array can contain names of
yaml hiera groups from the master. These groups will be
imported in the data hierarchy of the `client` puppetserver.
The name of a group must be provided without the `yaml`
extension. For instance with the value `[ 'foo', 'bar' ]`,
the hiera group files `foo.yaml` and `bar.yaml` will be
imported in the `client` puppetserver from the master. A
`client` puppetserver has its own hierarchy but it can be
useful to import some data from the parent `autonomous`
puppetserver.

Whatever the value of the `groups_from_master` parameter,
the file `common.yaml` of the parent `autonomous`
puppetserver will be always imported in the `client`
puppetserver. Furthermore, it the global variable
`$::datacenter` is defined, the file
`datacenter/${::datacenter}.yaml`will be automatically
imported from the parent `autonomous` puppetserver.

The `mcrypt_pwd` parameter is a mandatory parameter which
must be a non-empty string. Every day, `/etc/` will be saved
in `/home/ppbackup/etc/` in a file `etc_${date}.tar.gz.nc`
which is encrypted via the `mcrypt` command. And this
command uses the password set by the parameter `mcrypt_pwd`.
The goal is to have a safe backup because, in a puppet
server, the `/etc` directory contains lot of sensitive data.
To decrypt the file `etc_${date}.tar.gz.nc`, you have to
launch the command `mcrypt -d "etc_${date}.tar.gz.nc"` and
you have to give the password `mcrypt_pwd`.

The `authorized_backup_keys` parameter allows to set ssh
public keys which will be put in the `~/.ssh/authorized_keys`
file of the Unix account `ppbackup`. Indeed, this account
has a locked password and the only way to use this account
(for instance to make a `scp` of the backups) is to use ssh
public keys. The structure of this parameter must be the
same as the example above.

**Remark:** with the mechanism of backups in
`/home/ppbackup/etc/` and the `authorized_backup_keys`
parameter to put ssh public keys in the file
`authorized_keys` of the `ppbackup` account, you should be
able to set easily a cron task in another server to
retrieve. For instance, you could retrieve the backups with
a simple script like that:

```sh
#!/bin/sh

set -e

export LC_ALL='C'
export PATH='/usr/local/bin:/usr/bin:/bin'

sshtarget='ppbackup@puppet.domain.tld'
targzfile="/home/ppbackup/etc/etc_$(date '+%Y-%m-%d').tar.gz.nc"
backupdir='/backups/puppet'

timeout 180s scp "${sshtarget}:${targzfile}" "$backupdir"
find "$backupdir" -maxdepth 1 -type f -name 'etc_*.tar.gz.nc' -mtime +365 -delete
```



# A security point

The propagation of the CRL (Certificate Revocation List)
of the CA is an important point:

* puppetserver uses a CRL and must be restarted when the CRL
is updated. Typically, after a simple `puppet node clean $fqdn`,
the client is able to run puppet until the puppertserver has
been restarted.

* Same remark for puppetdb.




# TODO

* The `check-puppet-module.puppet` should list files in
  a module and check is each file is present in the file
  `checksums.json`.

* In the template `puppet.conf.epp`, a default value is
  given for two parameter in the lambda function (`modules_repository`
  and `strict_variables`). **Normally it's not necessary** because
  the type of this parameters is `Optional[...]` which means "ok if
  the value is undef" (different of "missing key is ok).
  But it's a regression of Puppet version 4.4.0 and it will be fixed
  in Puppet 4.4.1 (https://tickets.puppetlabs.com/browse/PUP-6064)

* Make a schema with puppetserver, puppetdb and postresql.

* A client uses the `$ssldir/crl.pem` file as CRL. This file
should be the same as the file `$ssldir/ca/ca_crl.pem` in
the puppet CA. We could imagine the CA which exports this
file `$ssldir/ca/ca_crl.pem` and puppet-agents retrieve this
file... Currently, if a "client" puppetserver P is revoked
by its "autonomous" puppetserver, the clients of puppetserver P
will always be able to do a puppet run (ie with a request to
puppet P) without any error.

* Create and use a specific account as owner of the puppet
code (hieradata and modules). Modify `install-modules.puppet`
to be executable for this account. If the command is run
by root, make a chown of the directory. Probably need to
change the Unix rights of the eyaml keys.

* Add an option to the `update-modules.puppet` command to
update only modules whose names match a regex. Before to
update a module, with `git pull` and `git diff origin/master`
check if the module has been changed (and don't update in
this case). It will be very to have this:
```sh
# * With --regex, we can filter the module name (without
#   --regex no filter).
# * If --list is present, then there is no update and we just
#   print the list of installed modules (with the filter if
#   present) with, for each module, the version installed and
#   the last version available on puppetforge.
update-modules.puppet [--list] [--regex='xxxx']
update-modules.puppet [-l] [-r 'xxxx']
```
To implement options in Ruby see
[here](http://ruby-doc.org/stdlib-1.9.3/libdoc/getoptlong/rdoc/GetoptLong.html).
To make a http request to puppetforge:
```ruby
require 'net/http'
require 'json'

# To have info concerning the module "puppetlabs-apt"
# The answer is a json file.
uri = URI.parse('https://forgeapi.puppetlabs.com/v3/modules/puppetlabs-apt')
response = Net::HTTP.get_response(uri)

json = JSON.parse(response.body)

puts json['current_release']['version']
```




