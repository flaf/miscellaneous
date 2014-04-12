class airtime {

  include 'airtime::install'
  include 'airtime::apache2'
  include 'airtime::config'
  include 'airtime::services'
  include 'icecast2'

  Class['airtime::install']
   -> Class['airtime::apache2']
   -> Class['airtime::config']
   -> Class['airtime::services']
   -> Class['icecast2']

}


