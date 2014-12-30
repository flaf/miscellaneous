class hosts::refresh {

  private("Sorry, ${title} is a private class.")

  exec { 'refresh-hosts':
    command     => '/usr/local/sbin/refresh-hosts',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
  }

}


