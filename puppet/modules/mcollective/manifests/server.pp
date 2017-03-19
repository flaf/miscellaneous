class mcollective::server {

  include '::mcollective::server::params'

  [
    $collectives,
    $private_key,
    $public_key,
    $service_enabled,
    $connector,
    $middleware_address,
    $middleware_port,
    $mcollective_pwd,
    $mco_tag,
    $mco_plugins,
    $puppet_ssl_dir,
    $puppet_bin_dir,
    $collectives_sorted,
    $supported_distributions,
  ] = Class['::mcollective::server::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ::homemade::fail_if_undef($private_key,        'mcollective::server::params::private_key',        $title)
  ::homemade::fail_if_undef($public_key,         'mcollective::server::params::public_key',         $title)
  ::homemade::fail_if_undef($middleware_address, 'mcollective::server::params::middleware_address', $title)
  ::homemade::fail_if_undef($middleware_port,    'mcollective::server::params::middleware_port',    $title)
  ::homemade::fail_if_undef($mcollective_pwd,    'mcollective::server::params::mcollective_pwd',    $title)
  ::homemade::fail_if_undef($puppet_ssl_dir,     'mcollective::server::params::puppet_ssl_dir',     $title)
  ::homemade::fail_if_undef($puppet_bin_dir,     'mcollective::server::params::puppet_bin_dir',     $title)

  include '::mcollective::common_paths'
  [
    $server_keys_dir,
    $allowed_clients_dir,
    $server_priv_key_path,
    $server_pub_key_path_for_server,
  ] = Class['::mcollective::common_paths']
  # For convenience.
  $server_pub_key_path = $server_pub_key_path_for_server

  ensure_packages([$mco_plugins],
                  {
                    ensure => present,
                    before => Service['mcollective'],
                    notify => Service['mcollective'],
                  }
                 )

  # mcollective::server have to manage this directory too
  # because the client keys are very sensitive. If a node is
  # no longer a mcollective client, we want to remove the
  # client keys (especially the client private key).
  include '::mcollective::client_keys_dir'

  file { [ "${server_keys_dir}",
           "${allowed_clients_dir}"
         ]:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0500',
    recurse => true,
    purge   => true,
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  file { $server_priv_key_path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $private_key,
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  file { $server_pub_key_path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $public_key,
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  # Import the exported public keys of mcollective clients with the tag.
  File <<| tag == $mco_tag |>> {
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  file { '/etc/puppetlabs/mcollective/server.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp( 'mcollective/server.cfg.epp',
                   {
                      'collectives'         => $collectives_sorted,
                      'server_priv_key_path'=> $server_priv_key_path,
                      'server_pub_key_path' => $server_pub_key_path,
                      'allowed_clients_dir' => $allowed_clients_dir,
                      'puppet_ssl_dir'      => $puppet_ssl_dir,
                      'puppet_bin_dir'      => $puppet_bin_dir,
                      'connector'           => $connector,
                      'middleware_address'  => $middleware_address,
                      'middleware_port'     => $middleware_port,
                      'mcollective_pwd'     => $mcollective_pwd,
                    }
                  ),
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  # In $::facts, we keep only some irrelevant keys.
  # Especially, we don't keep keys where values can change
  # at each puppet run (like 'system_uptime' for instance).
  $kept_facts = [ 'architecture',
                  'bios_release_date',
                  'bios_vendor',
                  'bios_version',
                  'blockdevices',
                  'chassistype',
                  'disks',
                  'dmi',
                  'domain',
                  'facterversion',
                  'filesystems',
                  'fqdn',
                  'hardwareisa',
                  'hardwaremodel',
                  'hostname',
                  'interfaces',
                  'ipaddress',
                  'ipaddress6',
                  'is_pe',
                  'is_virtual',
                  'kernel',
                  'kernelmajversion',
                  'kernelrelease',
                  'lsbdistcodename',
                  'lsbdistdescription',
                  'lsbdistid',
                  'lsbdistrelease',
                  'lsbmajdistrelease',
                  'macaddress',
                  'manufacturer',
                  'memorysize',
                  'memorysize_mb',
                  'netmask',
                  'netmask6',
                  'network',
                  'network6',
                  'networking',
                  'operatingsystem',
                  'operatingsystemmajrelease',
                  'operatingsystemrelease',
                  'os',
                  'osfamily',
                  'package_provider',
                  'partitions',
                  'physicalprocessorcount',
                  'processorcount',
                  'processors',
                  'productname',
                  'puppetversion',
                  'raid_controllers', # /!\ it's a custom fact.
                  'ruby',
                  'rubyplatform',
                  'rubysitedir',
                  'rubyversion',
                  'selinux',
                  'service_provider',
                  'staging_http_get',
                  'swapsize',
                  'swapsize_mb',
                  'timezone',
                  'virtual',
                  'clientcert',
                  'clientversion',
  ].reduce({}) |$memo, $item| {
    case $::facts[$item] {
      NotUndef: {
        $memo + { $item => $::facts[$item] }
      }
      default:  {
        $memo
      }
    }
  }

  $yaml_content = ::homemade::hash2yaml($kept_facts)

  file { '/etc/puppetlabs/mcollective/facts.yaml':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp( 'mcollective/facts.yaml.epp',
                    { 'yaml_content' => $yaml_content } ),
    # According to my tests, no restart of mcollective is
    # needed when this file is changed. Confirmed by R.I
    # Pienaar in #mcollective.
  }

  # WARNING: was a workaround for PUP-5232 in Trusty:
  #
  #       https://tickets.puppetlabs.com/browse/PUP-5232
  #
  # But this problem is fixed now. However, now, the content
  # of /etc/default/mcollective is completely irrelevant. There
  # is a ticket which is currently (Mars 18 2016) not resolved
  # about this:
  #
  #       https://tickets.puppetlabs.com/browse/MCO-754
  #
  # But it's not a problem, the variables set in this file are
  # just ignored by mcollectived. Furthermore it's better to let
  # the file in the strictly same version as in the puppet-agent
  # package.
  #
  #
  #if $::lsbdistcodename == 'trusty' {
  #  $etc_default = @(END)
  #    ### This file is managed by Puppet, don't edit it. ###
  #    #START=true
  #    #DAEMON_OPTS="--pid ${pidfile}"
  #    pidfile="/var/run/mcollectived-puppetlabs.pid"
  #    daemonopts="--pid=${pidfile} --config=/etc/puppetlabs/mcollective/server.cfg"

  #    | END

  #  file { '/etc/default/mcollective':
  #    ensure  => present,
  #    owner   => 'root',
  #    group   => 'root',
  #    mode    => '0644',
  #    content => $etc_default,
  #    before  => Service['mcollective'],
  #    notify  => Service['mcollective'],
  #  }
  #}

  $ensure_mco = $service_enabled ? {
    true  => 'running',
    false => 'stopped',
  }

  service { 'mcollective':
    ensure     => $ensure_mco,
    hasstatus  => true,
    hasrestart => true,
    enable     => $service_enabled,
  }

}


