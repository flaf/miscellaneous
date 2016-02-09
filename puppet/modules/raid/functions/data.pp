function raid::data {

  $megaraidsas2208rev05    = 'LSI Logic / Symbios Logic MegaRAID SAS 2208 [Thunderbolt] (rev 05)'
  $megaraidsas2208rev05bis = 'LSI Logic / Symbios Logic MegaRAID SAS 2108 [Liberator] (rev 05)'
  $hpproliantdl360gen9     = 'Hewlett-Packard Company Device 3239 (rev 01)'

  $controller2class = {
    $megaraidsas2208rev05    => 'megaraid',
    $megaraidsas2208rev05bis => 'megaraid',
    $hpproliantdl360gen9     => 'hpssacli',
  };

  {
    raid::params::raid_controllers          => $::raid_controllers, # it's a fact
    raid::params::controller2class          => $controller2class,

    raid::megaraid::supported_distributions => [ 'jessie' ],

    raid::hpssacli::supported_distributions => [ 'trusty', 'jessie' ],
  }

}


