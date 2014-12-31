class profiles::hosts::generic ($stage = 'network', ) {

  include '::profiles::hosts::params'
  $hosts_entries = $::profiles::hosts::params::hosts_entries
  $exported_ht   = $::profiles::hosts::params::exported_ht
  $tag_ht        = $::profiles::hosts::params::tag_ht

  if $exported_ht != undef {

    if $tag_ht == undef {
      fail("Class ${title}, exported hosts entries exist but no tag found.")
    }

    # Contruct ::network::hosts_entry resources in hashes.
    $resources_ht = str2hash(inline_template('
      <%-
        resources_ht = {}
        @exported_ht.each do |key, array|
          addr = array[0]
          array.shift
          resources_ht[key + "_" + @fqdn] = {
                                             "address"   => addr,
                                             "hostnames" => array,
                                            }
        end
      -%>
      <%= resources_ht.to_s -%>
    '))

    # With the $ht_resources hash, we create all the exported
    # hosts entries.
    $default = { tag => $tag_ht }
    create_resources('::network::hosts_entry', $resources_ht, $default)

  }

  class { '::network::hosts':
    hosts_entries => $hosts_entries,
    imported_tag  => $tag_ht,
  }

}


