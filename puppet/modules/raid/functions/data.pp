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
  }

  $sd = 'supported_distributions';

  {
    raid::params::raid_controllers    => $::raid_controllers, # it's a fact
    raid::params::classes2controllers => $classes2controllers,

    # This is an exception here. Normally, we should use
    # these parameters raid::foo::params::supported_distributions.
    # But in this module, ::raid is the unique public class and
    # the classes raid::foo are internal without parameter except
    # supported_distributions.
   "raid::megaraid::${sd}"            => [ 'jessie' ],
   "raid::hpssacli::${sd}"            => [ 'trusty', 'jessie' ],
   "raid::areca::${sd}"               => [ 'jessie' ],
  }

}


