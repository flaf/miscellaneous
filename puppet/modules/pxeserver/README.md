# Module description

This module just installs and manages a little PXE/DHCP server.
You can too manage a basic DNS server.

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

$host_records = {
  'nfs-1.dom.tld'    => [ 'nfs-1',    '192.168.13.50' ],
  'poller-1.dom.tld' => [ 'poller-1', '172.31.25.25'  ],
  'poller-2.dom.tld' => [ 'poller-2', '172.31.25.26'  ],
}

class { '::pxeserver::params':
  dhcp_confs             => $dhcp_confs,
  no_dhcp_interfaces     => [ 'eth0' ],
  apache_listen_to       => [],
  ip_reservations        => $ip_reservations,
  host_records           => $host_records,
  backend_dns            => [ '8.8.8.8', '8.8.4.4' ],
  cron_wrapper           => '',
  apt_proxy              => 'http://172.31.10.10:3142',
  puppet_collection      => 'PC1',
  pinning_puppet_version => '1.3.0-*',
  puppet_server          => 'puppet.domain.tld',
  puppet_ca_server       => 'puppet.domain.tld',
  puppet_apt_url         => 'http://apt.puppetlabs.com',
  puppet_apt_key         => 'http://apt.puppetlabs.com/pubkey.gpg',
}

include '::pxeserver'
```


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

In the case where you don't use DHCP relay, each `range +
netmask` in the `dhcp_confs` parameter must match with one
address of the host interfaces.

The `no_dhcp_interfaces` parameter allows to set several
`no-dhcp-interface=<interface>` instructions in the dnsmask
configuration to disable DHCP on specific interfaces. The
default value of this parameter is `[]`, ie DHCP is enabled
on all host interfaces.

The parameter `apache_listen_to` allows to set the Apache
option `Listen`:
* With the value `[]` (the default), we have `Listen 80`
  in the Apache configuration (Apache will listen to all
  interfaces on the port 80).
* With the value `[ '192.168.23.254', '192.168.24.254' ]`,
  Apache will listen to 192.168.23.254 and 192.168.24.254
  on the port 80.

The `ip_reservations` parameter must have the structure
above but can be the empty hash `{}` which its default
value, ie no IP reservation.

The `host_records` parameter allows to set several
`host-record=<name1>,<name2>,...,<IP-address>` instructions
in the dnsmask configuration (a key of the hash
`host_records` is the value of `<name1>`). The default value
this parameter is `{}` ie no host record at all. In this
case, the DNS service is completely disabled. If enabled,
the DNS server forwards the DNS requests to the DNS servers
set in the local file `/etc/resolv.conf` via the
`nameserver` instructions, unless the parameter
`backend_dns` is set.

The `backend_dns` parameter allows dnsmasq to use another
DNS servers that the DNS mentioned in `/etc/resolv.conf`
(via the `nameserver` instruction). The default value of
this parameter is `[]`. In this case, dnsmasq uses the DNS
servers mentioned in `/etc/resolv.conf` (this is the default
behavior of dnsmasq). But if this parameter is not empty, in
this case dnsmasq uses the DNS servers mentioned in this
parameter.

The `cron_wrapper` parameter allows to add a wrapper command
on the weekly cron task which downloads and updates the
`netboot.tar.gz` files for each provided distribution. It
can be useful if you want, for instance, add a command to
monitor the cron (and for instance check the return value).

The `apt_proxy` parameter allows to set a APT proxy
in the preseed files. If not set, its default value
is `''` (an empty string) and no APT proxy is set in
this case.

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
  $my_text_help = @(END)
    Blabla blabla blabla...
    Blabla blabla blabla...
    Blabla blabla blabla...
    |- END

  $pxe_entries = {

    # [...]

    'auto-documented-id' => {
      #'insert_begin'               => 'MENU BEGIN Install foo blabla blabla',
      'insert_begin'               => 'MENU BEGIN Expert installations',
      'distrib'                    => 'trusty',
      'menu_label'                 => '[trusty] bla bla bla',
      'text_help'                  => $my_text_help,
      'apt_proxy'                  => '',
      'partman_early_command_file' => 'nothing',
      'partman_auto_disk'          => '/dev/sda',
      'skip_boot_loader'           => false,
      'late_command_file'          => 'nothing',
      'install_puppet'             => true,
      'permitrootlogin_ssh'        => true,
      #'insert_end'                 => 'MENU END',
    },

    # [...]

  }
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
`partman_early_command_file` but for the `late_command`
instruction in the preseed. Its default value is
`"$id/late_command"` and, in this case, **you must create
the file `"files/$id/late_command"` in the module**. Like
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

The keys `insert_begin` and `insert_end` allow to insert
any content before and after the PXE entry. For instance
with:

```conf
MENU BEGIN Blaba blabla # via `insert_begin`
    # [...]
MENU END                # via `insert_end`
```

you can create menu where each PXE entry will be a sub-menu
of this menu. Another example: the `MENU SEPARATOR`
instruction allows to insert an empty line.


# Remark

When new distributions will be added in this module, try to
keep just 2 template files for the preseeds:
- one for the Debian family,
- and one for the Ubuntu family.


