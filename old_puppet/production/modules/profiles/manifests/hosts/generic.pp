class profiles::hosts::generic ($stage = 'network', ) {

  # Should be removed. Present here only to apply
  # the specific stage parameter to this class.
  require '::hosts'

  $network_conf      = hiera_hash('network')
  $hosts_entries     = $network_conf['hosts_entries']
  $hosts_entries_tag = $network_conf['hosts_entries_tag']

  if $hosts_entries == undef {
    fail("Problem in class ${title}, `hosts_entries` data not retrieved")
  }

  # The magic tag will used only for the exported host entries.
  $default = { magic_tag => $hosts_entries_tag }
  create_resources('::hosts::entry', $hosts_entries, $default)

  if $hosts_entries_tag != undef {
    class { '::hosts::collect':
      magic_tag => $hosts_entries_tag,
    }
  }

  # Should be removed. Present here only to apply
  # the specific stage parameter to this class.
  include '::hosts::refresh'

}


