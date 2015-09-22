class network::hosts (
  Hash[ String[1], Array[String[1],1] ] $entries,
  String                                $from_tag,
  Array[String[1], 1]                   $supported_distributions,
  String[1]                             $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # We check the addresses in $entries.
  $entries.each |$addr_x, $names| {

    # $addr_x is an "eXtended" address with maybe =~ /^@@/.
    # We remove the optional "@@".
    $addr = $addr_x.regsubst(/^@@/, '')

    if !$addr.is_ip_address {
      fail("${title}: the address value `${addr_x}` is not valid.")
    }

  }

  # We check if there are some exported entries.
  $exported = ! $entries.filter |$addr_x, $names| { $addr_x =~ /^@@/ }.empty

  if $exported {

    if $from_tag == '' {
      fail("${title}: you want to export some hosts entries but the tag is empty.")
    }

    # The hosts file will not be managed directly.
    

  } else {
    # We are going to manage the hosts file via a classical template.
    file { '/etc/hosts':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('network/hosts.epp', { 'entries' => $entries }),
    }
  }

}


