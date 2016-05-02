# Module description

This module just installs and manages a little PXE/DHCP server
(not DNS service is installed).

# Usage

Here is an example:

```puppet
$dhcp_confs = {
  'vlan1' => {
    'netname'    => 'adm@dc2',                                           # Mandatory
    'range'      => ['172.31.200.100', '172.31.200.150', '255.255.0.0'], # Mandatory
    'router'     => '172.31.0.1',                                        # Optional
    'dns-server' => ['172.31.0.11', '172.31.0.12'],                      # optional
  },
  'vlan13' => {
    'netname'    => 'nfs@dc2',
    'range'      => ['192.168.13.100', '192.168.13.150', '255.255.255,0'],
  },
}

$ip_reservations = {
  '0c:c4:7a:6a:e0:8c' => [ '192.168.13.50', 'nfs-1' ],
  '0c:c4:7a:6a:5f:ec' => [ '172.31.25.25', 'poller-1' ],
  '9e:72:c8:38:38:2c' => [ '172.31.25.26', 'poller-2' ],
}

class { '::pxeserver::params':
  dhcp_confs             => $dhcp_confs,
  ip_reservations        => $ip_reservations,
  puppet_collection      => 'PC1',
  pinning_puppet_version => '1.3.0-*',
  puppet_server          => 'puppet.domain.tld',
  puppet_ca_server       => 'puppet.domain.tld',
  puppet_apt_url         => 'http://apt.puppetlabs.com',
  puppet_apt_key         => 'http://apt.puppetlabs.com/pubkey.gpg',
}

include '::pxeserver'
```

# Warning

With this module, the host will have a DHCP service and
a TFTP service (to provide boot PXE) but no DNS service
is installed.

This module should be used only with hosts which have
just only **one interface** (or two interfaces if you take
into account `lo` of course). Outside of this condition,
there is no warranty that the module works well.


# Parameters of the class `pxeserver::params`

The `dhcp_confs` parameter is a hash with the structure
above. The value of the `range` key is an array with this
form `[ 'dhcp-ip-min', 'dhcpip-max', 'netmask' ]`. The
netmask must be provided as an IP address (not an integer).
The keys `'vlan1'`, `vlan13` above are the tags of the
networks. The tag of a network is set in the configuration
of dnsmasq with the instructions `dhcp-range` and used in
the instructions `dhcp-option` etc. The default value of
this parameter is `undef` so you must provide a value
explicitly.

The `ip_reservations` parameter must have the structure
above but can be the empty hash `{}` which its default
value, ie no IP reservation.

The remaining parameters concerned Puppet and, for each, the
default value is `undef` and you must provide a value.
Indeed, the PXE server provides installation where the
puppet-agent package is automatically installed with a
specific version. All these parameters are clear. Just a
remark concerning the parameter `puppet_apt_key`. This
parameter must be any url where the APT key of Puppetlabs
will be downloaded via wget during the PXE installation.


# How to add a custom PXE entry

You have to modify the file `manifest/manifests/params.pp`
and add an entry in the hash `pxe_entries`:

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

`distrib` must be the codename of the distribution in
lowercase. This parameter is mandatory and has no default
value.

`menu_label` and `text_help` are mandatory too (no default
value). These parameters are strings which described the PXE
entry.  Just on line for `menu_label` and few lines for
`text_help` (about 7 maximum).

`apt_proxy` is a string which represents the address of a
http proxy for APT. For instance `'http://my-proxy:3142'`.
If not provided, the default value of this parameter is an
empty string which means "no APT proxy".

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
is special. With this value, no command will be added in the
`partman_early_command` part (and no file must be created in
the module in this case).

`partman_auto_disk` is a string to define the disk (like
`/dev/sda` etc.) where the OS will be installed. The special
value `''` (ie an empty string) is possible. In this case,
mount points should be set manually during the installation.
The default value of this parameter is `''`.

`skip_boot_loader` is a boolean. If set to `true` all the
part concerning the Grub installation will be removed from
the preseed file. It can be useful is you want to do a
special installation of Grub with `late_command`. The
default value of this parameter is `true`.

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


