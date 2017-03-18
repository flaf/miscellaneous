function basic_ssh::data {

  # In fact, 'without-password' and 'prohibit-password' are
  # synonyms but 'prohibit-password' is accepted since
  # Xenial and is less ambiguous than 'without-password'.
  $default_permitrootlogin = $::facts['os']['distro']['codename'] ? {
    /^(trusty|jessie)$/ => 'without-password',
    default             => 'prohibit-password',
  }

  $supported_distributions = [
                               'trusty',
                               'xenial',
                               'jessie',
                             ];

  {
    basic_ssh::server::params::permitrootlogin         => $default_permitrootlogin,
    basic_ssh::server::params::supported_distributions => $supported_distributions,

    basic_ssh::client::params::supported_distributions => $supported_distributions,
  }

}


