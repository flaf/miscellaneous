function gitlab::data {

  $fqdn = $::facts.dig('networking', 'fqdn');

  {
    gitlab::params::external_url            => "http://${fqdn}",
    gitlab::params::ldap_conf               => 'none',
    gitlab::params::custom_nginx_config     => [],
    gitlab::params::backup_retention        => 2,
    gitlab::params::backup_cron_wrapper     => '',
    gitlab::params::backup_cron_hour        => 3,
    gitlab::params::backup_cron_minute      => 0,
    gitlab::params::ssl_cert                => '',
    gitlab::params::ssl_key                 => '',
    gitlab::params::supported_distributions => ['trusty'],
  }

}


