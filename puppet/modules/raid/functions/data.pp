function raid::data {

  $classes2controllers = {
    'megaraid' => [
                   'LSI Logic / Symbios Logic MegaRAID SAS 2208 [Thunderbolt] (rev 05)',
                   'LSI Logic / Symbios Logic MegaRAID SAS 2108 [Liberator] (rev 05)',
                  ],
    'hpssacli' => [
                   'Hewlett-Packard Company Device 3239 (rev 01)',
                   'Hewlett-Packard Company Smart Array Gen9 Controllers (rev 01)',
                  ],
    'areca'    => [
                   'Areca Technology Corp. ARC-1880 8/12 port PCIe/PCI-X to SAS/SATA II RAID Controller (rev 05)',
                  ],
  };

  {
    raid::params::raid_controllers          => $::raid_controllers, # it's a fact
    raid::params::classes2controllers       => $classes2controllers,

    raid::megaraid::supported_distributions => [ 'jessie' ],

    raid::hpssacli::supported_distributions => [ 'trusty', 'jessie' ],

    raid::areca::supported_distributions    => [ 'jessie' ],
  }

}


