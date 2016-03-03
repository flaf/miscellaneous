function mongodb::data {

  {
    mongodb::params::bind_ip         => [ '0.0.0.0' ],
    mongodb::params::port            => 27017,
    mongodb::params::auth            => false,
    mongodb::params::replset         => "mongo-${::domain}",
    mongodb::params::smallfiles      => true,
    mongodb::params::keyfile         => undef,
    mongodb::params::quiet           => true,
    # loglevel is a bad name for a class because it's
    # the name of metaparameter so loglevel becomes
    # log_level.
    mongodb::params::log_level       => 0,
    mongodb::params::logpath         => '/var/log/mongodb/mongodb.log',
    mongodb::params::databases       => {},
    mongodb::supported_distributions => ['trusty'],
  }

}


