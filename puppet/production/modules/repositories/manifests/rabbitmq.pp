# Puppet class to manage the RabbitMQ APT repository.
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
#  include '::repositories::rabbitmq'
#
class repositories::rabbitmq {

  # Fingerprint of the APT key:
  #
  # RabbitMQ Release Signing Key <info@rabbitmq.com>
  #
  # To install this APT key:
  #
  #   url='https://www.rabbitmq.com/rabbitmq-signing-key-public.asc'
  #   wget -q -O- "$url" | apt-key add -
  #
  $key = 'F78372A06FF50C80464FC1B4F7B8CEA6056E8E56'

  apt::source { 'rabbitmq':
    comment     => 'The RabbitMQ repository.',
    location    => 'http://www.rabbitmq.com/debian/',
    release     => 'testing', # Not refers to the distribution.
    repos       => 'main',
    key         => $key,
    include_src => false,
  }

}


