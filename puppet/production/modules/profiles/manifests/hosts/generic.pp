class profiles::hosts::generic ($stage = 'network', ) {

  include '::profiles::hosts::params'
  $hosts_entries     = $::profiles::hosts::params::hosts_entries
  $exported_ht       = $::profiles::hosts::params::exported_ht
  $hosts_entries_tag = $::profiles::hosts::params::hosts_entries_tag

  if $exported_ht != undef {

    if $hosts_entries_tag == undef {
      fail("Class ${title}, exported hosts entries exist but no tag found.")
    }

    # Updating of $ht_resources.
    $ht_resources = {}
    eval_ruby_code('
        ht           = $arg1
        fqdn         = $arg2
        ht_resources = $arg3

        ht.each do |key, array|
          addr = array[0]
          arr = array.clone # Copy the array to not change ht.
          arr.shift         # Remove the first element in arr.
          hostnames = arr
          new_key = key + "_" + fqdn
          ht_resources[new_key] = {
                                   "address"   => addr,
                                   "hostnames" => hostnames
                                  }
        end
      ', $exported_ht, $::fqdn, $ht_resources)

    # With the $ht_resources hash, we create all the exported
    # hosts entries.
    $default = { tag => $hosts_entries_tag }
    create_resources('::network::hosts_entry', $ht_resources, $default)

  }

  class { '::network::hosts':
    hosts_entries => $hosts_entries,
    imported_tag  => $hosts_entries_tag,
  }

}


