#
# Private class.
#
define ceph::radosgw (
  $cluster_name = 'ceph',
  $account,
  $admin_mail,
){

  private("Sorry, ${title} is a private class.")

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  require '::ceph::radosgw::packages'

  $options  = "-c /etc/ceph/${cluster_name}.conf -n client.${account}"
  $cmd_fcgi = "#!/bin/sh\nexec /usr/bin/radosgw ${options}\n"

  file { '/var/www/s3gw.fcgi':
    ensure  => present,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0754',
    content => $cmd_fcgi,
  }

  #file { "/etc/apache2/conf-available/ceph-cluster-.conf"
  #}

}


