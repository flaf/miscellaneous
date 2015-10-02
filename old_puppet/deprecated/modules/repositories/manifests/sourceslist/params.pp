#
# This is a private class.
#
class repositories::sourceslist::params {

  case $::lsbdistcodename {
    wheezy: {
      $url = 'http://ftp.debian.org/debian/'
    }
    trusty: {
      $url = 'http://archive.ubuntu.com/ubuntu/'
    }
    default: {
      # The sourceslist class will fail with an empty string.
      $url = ''
    }
  }

}


