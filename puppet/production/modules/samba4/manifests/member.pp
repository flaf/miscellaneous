class samba4::member {

  include 'samba4::common::install'
  include 'samba4::member::config'

  Class['samba4::common::install']
    -> Class['samba4::member::config']

}


