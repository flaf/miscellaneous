class apt::backports {

  require 'apt'

  source_list { 'backports':
    content => "deb http://ftp.fr.debian.org/debian ${lsbdistcodename}-backports main contrib non-free\n\n",
  }

}


