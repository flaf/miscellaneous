class samba4::dc {

  include 'samba4::common::install'
  include 'samba4::dc::config'

  Class['samba4::common::install']
    -> Class['samba4::dc::config']

}


