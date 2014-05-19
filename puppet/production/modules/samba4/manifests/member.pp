#==Action
#
# Install and configure a Samba4 member of domain controller.
# Tested with Debian Wheezy.
#
# /!\ You must first install the domain controller.
# /!\ After installation, you must join the domain
# /!\ manually with:
# /!\
# /!\   invoke-rc.d samba stop
# /!\   invoke-rc.d winbind stop
# /!\   net ads join -U administrator%passwd
# /!\   invoke-rc.d samba start
# /!\   invoke-rc.d winbind start
# /!\
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
#   ip_dc: '172.31.1.1' # IP of the domain controller
#   ntp_server: '172.31.0.1'
#
#
class samba4::member {

  include 'samba4::common::install'
  include 'samba4::member::install'
  include 'samba4::common::config'
  include 'samba4::member::config'

  Class['samba4::common::install']
    -> Class['samba4::member::install']
    -> Class['samba4::common::config']
    -> Class['samba4::member::config']

}


