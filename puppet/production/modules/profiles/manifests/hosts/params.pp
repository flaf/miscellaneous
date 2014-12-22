class profiles::hosts::params {

  $network_conf  = hiera_hash('network')

  $hosts_entries = $network_conf['hosts_entries']

  # /!\ Don't use "exported_hosts_entries" for the name
  # of the variable, because it's a fact (exactly like
  # $fqdn is a bad name for a variable).
  $exported_ht       = $network_conf['exported_hosts_entries']

  $hosts_entries_tag = $network_conf['hosts_entries_tag']

  # No "undef" test for the variables because we accept
  # that these variables can be undef.

}


