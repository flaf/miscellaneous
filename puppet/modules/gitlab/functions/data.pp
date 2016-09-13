function gitlab::data {

  $fqdn = $::facts.dig('networking', 'fqdn');

  {
    gitlab::params::external_url            => "http://${fqdn}",
    gitlab::params::ldap_conf               => 'none',
    gitlab::params::supported_distributions => ['trusty'],
  }

}


