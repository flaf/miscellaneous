# This is a private class.
class mcollective::package {

  require '::repository::puppet'
  ensure_packages(['puppet-agent'], { ensure => present, })

}


