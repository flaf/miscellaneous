class mcollective::client (
  $client_private_key,
  $client_public_key,
  $middleware_server,
  $middleware_port,
  $mcollective_pwd,
  $ssl_dir = '/var/lib/puppet/ssl',
) {

  $packages = [
               'mcollective-client',
               'mcollective-shell-client',
              ]

  ensure_packages($packages, { ensure => present, })

}

