# This class should be a private class but when it's
# encapsulated in a "profiles" class with a specific stage
# metaparameter, you need to explicitly include this class
# in the "profiles" class.
#
class hosts::refresh {

  #private("Sorry, ${title} is a private class.")

  exec { 'refresh-hosts':
    command     => '/usr/local/sbin/refresh-hosts.puppet',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
  }

}


