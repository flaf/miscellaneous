define repository::aptkey (
  String[1]           $id,
  Optional[String[1]] $keyserver  = undef,
  Optional[String[1]] $http_proxy = undef,
  Optional[String[1]] $source     = undef,
) {

  if ($source !~ Undef and $keyserver !~ Undef) {
    @("END"/L).fail
      $title: sorry the parameters `keyserver` and `source` can not \
      be set together. These parameters are mutually exclusive.
      |-END
  }

  include '::repository::aptkey::params'
  $supported_distributions = $::repository::aptkey::params::supported_distributions
  ::homemade::is_supported_distrib($supported_distributions, $title)

  $keyserver_final = $keyserver ? {
    undef   => $::repository::aptkey::params::keyserver,
    default => $keyserver,
  }

  $http_proxy_final = $http_proxy ? {
    undef   => $::repository::aptkey::params::http_proxy,
    default => $http_proxy,
  }

  if ($source =~ Undef and $keyserver_final =~ Undef) {
    @("END"/L).fail
      $title: sorry all parameters `source`, `keyserver` and
      `repository::aptkey::params::keyserver` are undef so,
      no way defined to retrieve the APT key.
      |-END
  }

  $key = $id.regsubst(' ', '', 'G').regsubst(/^0x/, '')

  $cmd_apt_key_add = $source ? {
    NotUndef => "wget -O- '${source}' | apt-key add -",
    default  => "apt-key adv --keyserver '${keyserver_final}' --recv-keys '${key}'",
  }

  # In fact, it's possible to have $http_proxy_final == undef.
  $envvar = $http_proxy_final ? {
    undef   => undef,
    default => "http_proxy=${http_proxy_final}",
  }

  $cmd_apt_key_test = @("END"/L$)
    apt-key finger | awk 'tolower(\$2) == "fingerprint" {print}' | \
    sed -r 's/key[[:space:]]+fingerprint = //i' | tr -d ' ' | \
    grep -q '^${key}\$'
    |-END

  exec { "add-apt-key-${title}":
    environment => $envvar,
    command     => $cmd_apt_key_add,
    user        => 'root',
    group       => 'root',
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    logoutput   => 'on_failure',
    unless      => $cmd_apt_key_test,
    timeout     => 10,
    tries       => 2,
    try_sleep   => 2,
  }

  #notify { "${title}-apt-key-add":
  #  message => "$envvar ${cmd_apt_key_add}",
  #}
  #
  #notify { "${title}-apt-key-test":
  #  message => $cmd_apt_key_test,
  #}

}


