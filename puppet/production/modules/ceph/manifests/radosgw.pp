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

  file { '/var/www/s3gw.fcgi':
    ensure  => present,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0754',
    content => "#!/bin/sh\nexec /usr/bin/radosgw -c /etc/ceph/${cluster_name}.conf -n",
  }

  #file { "/etc/apache2/conf-available/ceph-cluster-.conf"
  #}

}


