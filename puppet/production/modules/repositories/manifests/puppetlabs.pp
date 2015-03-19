# Puppet class to manage a specific APT repositories
# of Puppetlabs.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib and Puppetlabs-apt.
#
# == Parameters
#
# No parameter.
#
# == Sample Usage
#
#  include '::repositories::puppetlabs'
#
class repositories::puppetlabs {

  # Fingerprint of the APT key:
  #
  #   Puppet Labs Release Key (Puppet Labs Release Key) <info@puppetlabs.com>
  #
  # To install this APT key:
  #
  #   url='http://apt.puppetlabs.com/keyring.gpg'
  #   wget -q -O- "$url" | apt-key add -
  #
  $key = '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30'

  apt::source { 'puppetlabs':
    comment     => 'The Puppetlabs repository.',
    location    => 'http://apt.puppetlabs.com',
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => $key,
    include_src => false,
  }

}


