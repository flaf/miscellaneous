function eximnullclient::data {

  $dc_smarthost = $::facts.dig('networking', 'domain').then |$domain| {
    [ { 'address' => "smtp.${domain}", 'port' => 25 } ]
  };

  {
    eximnullclient::params::dc_smarthost            => $dc_smarthost,
    eximnullclient::params::redirect_local_mails    => '',
    eximnullclient::params::prune_from              => true,
    eximnullclient::params::supported_distributions => ['trusty', 'jessie'],
  }

}


