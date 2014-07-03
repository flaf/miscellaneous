class profiles::apache_poller {

  include '::apache_poller'
  class { 'apache':
    default_vhost => false,
  }
  apache::listen { '127.0.0.1:80': }
  include 'apache::mod::perl'

  $scriptaliases = [
    {
      alias => '/bin/',
      path  => '/usr/lib/cgi-bin/',
    },
  ]

  $custom_fragment ='
  <Directory "/usr/lib/cgi-bin">
      AllowOverride None
      SetHandler perl-script
      PerlResponseHandler ModPerl::Registry
      PerlOptions -ParseHeaders
      Options +ExecCGI -MultiViews -SymLinksIfOwnerMatch
      Order allow,deny
      Allow from all
  </Directory>'

  apache::vhost { $fqdn:
    add_listen      => false,
    ip              => '127.0.0.1',
    port            => '80',
    docroot         => '/srv',
    scriptaliases   => $scriptaliases,
    custom_fragment => $custom_fragment,
    log_level       => 'warn',
  }

}


