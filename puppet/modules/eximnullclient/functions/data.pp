function eximnullclient::data {

  $dc_smarthost = $::facts.dig('networking', 'domain').then |$domain| {
    [ { 'address' => "smtp.${domain}", 'port' => 25 } ]
  }

  $supported_distributions = [
                               'trusty',
                               'xenial',
                               'jessie'
                             ];

  {
    eximnullclient::params::dc_smarthost            => $dc_smarthost,
    eximnullclient::params::passwd_client           => [],
    eximnullclient::params::redirect_local_mails    => undef, # Default value allowed here.
    eximnullclient::params::prune_from              => true,
    eximnullclient::params::supported_distributions => $supported_distributions,
  }

}


