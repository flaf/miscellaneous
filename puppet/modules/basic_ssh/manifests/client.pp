class basic_ssh::client {

  include '::basic_ssh::client::params'

  ensure_packages( [ 'openssh-client' ], { ensure => present } )

}


