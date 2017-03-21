class network::hosts {

  include '::network::hosts::params'

  [
   $entries_completed,
   $hosts_from_tag,
   $supported_distributions,
  ] = Class['::network::hosts::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # Commodity.
  $entries  = $entries_completed
  $from_tag = $hosts_from_tag

  # We check the addresses in $entries.
  $entries.each |$addr_x, $names| {

    # $addr_x is an "eXtended" address with maybe =~ /^@@/.
    # We remove the optional "@@".
    $addr = $addr_x.regsubst(/^@@/, '')

    if !$addr =~ Stdlib::Compat::Ip_address {
      fail("${title}: the address value `${addr_x}` is not valid.")
    }
    if $addr == '127.0.0.1' {
      fail("${title}: the address value `127.0.0.1` mustn't be used as hosts entry.")
    }

  }

  $exported_entries  = $entries.filter |$addr_x, $names| { $addr_x =~ /^@@/ }
  $my_entries        = $entries.filter |$addr_x, $names| { $addr_x !~ /^@@/ }
  $tag_hosts_entries = 'hosts-entry'

  # We check if there are some exported entries.
  $exported = ! $exported_entries.empty

  # TODO: [i] in the case where hosts entries are exported,
  # if the exported resources disappear from the Puppetdb,
  # the hosts entries disappear too and it could be annoying.
  # Is it better to let "purge => false" and force an manually
  # remove of outdated hosts entries?
  file { '/etc/hosts.puppet.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true, # [i]
    force   => true,
    # The remove of a file must trigger a refresh.
    notify  => Exec['refresh-hosts'],
  }

  file {'/etc/hosts.puppet.d/README':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "Directory managed by Puppet, don't touch it.\n",
    require => File['/etc/hosts.puppet.d'],
  }

  file { '/usr/local/sbin/refresh-hosts.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => epp('network/refresh-hosts.puppet.epp',
                   { 'my_entries' => $my_entries }
                  ),
  }

  exec { 'refresh-hosts':
    command     => '/usr/local/sbin/refresh-hosts.puppet',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/usr/local/sbin/refresh-hosts.puppet'],
  }

  # Cases where the /etc/hosts file will be not managed directly,
  # ie the host exports some host entries or the host wants to retrieve
  # host entries from a specific tag (which is a non-empty string).
  if $exported or $from_tag =~ String[1] {

    if $from_tag == '' {
      fail("${title}: you want to export some hosts entries but the tag is empty.")
    }

    # The hosts file will not be managed directly.
    $content_hosts = undef

    # Export.
    $exported_entries.each |$addr_x, $names| {

      $addr          = $addr_x.regsubst(/^@@/, '')
      $concat_names  = $names.join(' ')

      @@file { "/etc/hosts.puppet.d/${::fqdn}${addr_x}.conf":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "${addr} ${concat_names}",
        tag     => [ $from_tag, $tag_hosts_entries],
      }

    }

    # Collect of exported hosts entries.
    File <<| tag == $from_tag and tag == $tag_hosts_entries |>> {
      notify => Exec['refresh-hosts'],
    }

  } else {

    # We are going to manage the hosts file via a classical template.
    $content_hosts = epp('network/hosts.epp', { 'entries' => $entries })

  }

    file { '/etc/hosts':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $content_hosts,
    }

}


