class wget {

  include '::wget::params'

  [
    $http_proxy,
    $https_proxy,
    $supported_distributions,
  ] = Class['::wget::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $undefined = 'undefined'
  $unmanaged = 'unmanaged'

  ensure_packages( 'wget', { ensure => present } )

  # Warning: comments are not authorized at end of lines in
  # "http_proxy" or "https_proxy" instructions. For instance,
  # with Xenial, if I have this line in /etc/wgetrc:
  #
  #     https_proxy = http://proxy.athome.priv:3128 # Line edited by Puppet.
  #
  # when I try a basic "wget https://www.google.fr", I have
  # this error:
  #
  #     Error parsing proxy URL http://proxy.athome.priv:3128 # Line edited by Puppet.: Bad port number.

  $line_http_proxy = $http_proxy ? {
    "${undefined}" => '#http_proxy = NOT DEFINED (edited by Puppet)',
    default        => "http_proxy = ${http_proxy}",
  }

  $line_https_proxy = $https_proxy ? {
    "${undefined}" => '#https_proxy = NOT DEFINED (edited by Puppet)',
    default        => "https_proxy = ${https_proxy}",
  }

  unless ($http_proxy == $unmanaged) {
    file_line { 'edit-http-proxy-in-wgetrc':
      path    => '/etc/wgetrc',
      match   => '^[[:space:]]*#?[[:space:]]*http_proxy[[:space:]]*=.*$',
      line    => $line_http_proxy,
      require => Package['wget'],
    }
  }

  unless ($https_proxy == $unmanaged) {
    file_line { 'edit-https-proxy-in-wgetrc':
      path    => '/etc/wgetrc',
      match   => '^[[:space:]]*#?[[:space:]]*https_proxy[[:space:]]*=.*$',
      line    => $line_https_proxy,
      require => Package['wget'],
    }
  }

}


