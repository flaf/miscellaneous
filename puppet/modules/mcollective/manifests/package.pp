# This is a private class.
class mcollective::package {

  ensure_packages( [ 'puppet-agent' ], { ensure => present } )

}


