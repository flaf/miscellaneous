class profiles::hosts::generic ($stage = 'network', ) {

  include '::profiles::hosts::params'
  $hosts_entries = $::profiles::hosts::params::hosts_entries

  class { '::network::hosts':
    hosts_entries => $hosts_entries,
  }

}


