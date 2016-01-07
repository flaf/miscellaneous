# Module description

This module just installs and manages a little PXE/DHCP server
(not DNS service is installed).

# Usage

Here is an example:

```puppet
class { '::pxeserver':
  dhcp_range              => [ '172.31.0.200', '172.31.0.250' ],
  dhcp_dns_servers        => [ '172.31.0.5', '172.31.0.6' ],
  dhcp_gateway            => '172.31.0.1',
  ip_reservations         => {
                              '20:cf:30:52:6a:56' => [ '172.31.100.1', 'srv-1' ],
                              '20:cf:30:52:6a:57' => [ '172.31.100.2', 'srv-2' ],
                             },
  puppet_collection       => 'PC1',
  pinning_puppet_version  => '1.3.0-*',
  puppet_server           => 'puppet.domain.tld',
  puppet_ca_server        => 'puppet.domain.tld',
}
```

# Warning

With this module, the host will have a DHCP service and
a TFTP service (to provide boot PXE) but no DNS service
is installed.

This module should be used only with hosts which have
just only **one interface** (or two interfaces if you take
into account `lo` of course). Outside of this condition,
there is no warranty that the module works well.


# Data binding

The `dhcp_range` parameter is mandatory.
The `ip_reservations` parameter is optional and its default
value is `{}` (a empty hash), ie no IP reservation.

The other parameters are optional and the module will try to
get smart default values from the data binding mechanism
from other modules.

* The default value of `dhcp_dns_servers` and `dhcp_gateway`
are retrieved from the data binding mechanism of the
`flaf-network` module.

* The default value of `puppet_collection` and `pinning_puppet_version`
are retrieved from the data binding mechanism of the
`flaf-repository` module.

* The default value of `puppet_server` and `puppet_ca_server`
are retrieved from the data binding mechanism of the
`flaf-puppetagent` module.

See the code of `./function/data.pp` for more details.


# How to add a custom PXE entry

You have to modify the file `manifest/conf.pp` and add an entry
in the hash `pxe_entries`:

```puppet
  $pxe_entries = {

  [...]

    'auto-documented-id' => {
      'distrib'    => 'trusty',
      'menu_label' => '[trusty] bla bla bla',
      'text_help'  => @(END),
        Blabla blabla blabla...
        Blabla blabla blabla...
        Blabla blabla blabla...
        |- END
      'apt_proxy'                  => '',
      'partman_early_command_file' => 'nothing',
      'partman_auto_disk'          => '/dev/sda',
      'skip_boot_loader'           => false,
      'late_command_file'          => 'nothing',
      'install_puppet'             => true,
      'permitrootlogin_ssh'        => true,
    },
```

`distrib` must be the codename of the distribution in lowercase.
This parameter is mandatory and has no default value.

`menu_label` and `text_help` are mandatory too (no default
value). These parameters are strings which described the
PXE entry.  Just on line for `menu_label` and few lines for
`text_help` (about 7 maximum).

`apt_proxy` is a string which represents the address of a
http proxy for APT. For instance `'http://my-proxy:3142'`.
If not provided, the default value of this parameter is
an empty string which means "no APT proxy".

`partman_early_command_file` is the relative name of the
file (in the `file/` directory of the module) which contains
the script which will be executed during the
`partman_early_command` part in the preseed. If not
provided, the default value of this parameter is
`$id/partman_early_command` where `$id` is the name of the
key in the `$pxe_entries` hash above. For instance, if you
define a PXE entry with the key name `trusty-mysql`, this
parameter will have the default value
`trusty-mysql/partman_early_command`, so that **you must
create the file `files/trusty-mysql/partman_early_command`
in the module** with the commands which will be executed
during the preseed installation. Generally, the default
value will be relevant but this parameter can be useful if
you want, for instance, used the same file in the module for
several PXE entry. For this parameter, the value `'nothing'`
is special. With this value, no command will be added in
the `partman_early_command` part (and no file must be
created in the module in this case).

`partman_auto_disk` is a string to define the disk (like
`/dev/sda` etc.) where the OS will be installed. The special
value `''` (ie an empty string) is possible. In this case,
mount points should be set manually during the installation.
The default value of this parameter is `''`.

`skip_boot_loader` is a boolean. If set to `true` all
the part concerning the Grub installation will be removed
from the preseed file. It can be useful is you want to
do a special installation of Grub with `late_command`.
The default value of this parameter is `true`.

`late_command_file` is the same parameter as
`partman_early_command_file` but for the `late_command` is
the preseed. Its default value is `$id/late_command` so
that, in this case, **you must create the file
`files/$id/late_command` in the module**. Like
`partman_early_command_file`, with the value `nothing` no
file must be created in the module and no command will be
added in the `late_command` part (except maybe the commands
to install the puppet agent or to allow root login via ssh)

`install_puppet` is a boolean. If set to `true`, commands to
install the puppet agent will be automatically added in the
`late_command` part (with the version of the
`pinning_puppet_version` parameter) and a command to launch
a puppet run (with good options) will be added in the bash
history of root. The default value of this parameter is
`true`.

`permitrootlogin_ssh` is a boolean. If set to `true`,
commands to allow root login via ssh will be automatically
added in the `late_command` part. The default value of this
parameter is `true`.




# Remark

When new distributions will be added in this module, try to
keep just 2 template files for the preseeds:
- one for the Debian family,
- and one for the Ubuntu family.


# TODO

* `tags_excluded` and `tags_included` not yet token into account.
* Update the README.
* Some variables needs to be ckecked.
* Some data which belong to other modules are retrieved via a
  lookup function but should be retrieved via the params classes
  of these modules, when they will be implemented.


