#==Action
#
# Install and configure a Samba4 domain controller.
# Tested with Debian Wheezy.
#
# /!\ Don't forget to change the adminstrator's password
# /!\ after installation.
#
#
# This class depends on;
# - puppetlabs-stdlib
# - puppetlabs-apt
#
#
#==Hiera
#
# samba4:
#   dns_forwarder: '172.31.0.1'
#
#
class samba4::dc {

  include 'samba4::common::install'
  include 'samba4::dc::config'

  Class['samba4::common::install']
    -> Class['samba4::dc::config']

}


