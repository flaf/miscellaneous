class profiles::users::generic {

  $pwd = '$6$094b7812959aecfa$f775hOOqPTE83UTRQIYgh1JeEgbHFcT3W6R8PUCOb7NiPtqV79XXhUJQ0Wt6W0O8RNLm2YXwGxEExYyyyIgdN0'

  $pub_key = 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCwetNOQ3Iq25gIIg1ZL8unmdOCzLINnd5owsQ32vop+pVZzohmHNMzj0nVt1FkLnO/aW7+RMj1wbcfz3z1GMLN3XHcjF5bdV7qFjO7NThCfEcUbMKRy/ODMQpCHks+AuHRuqE/lcS9EMvGbix/RdSBhLvYQYYbS02R3Nik1md54Qhxv+JondHIM2QIEepJfdshEJ9yjofAsMQqQ6U4UW42G1LN1F7K7tFjo9A4LcuzT/KzTFR6SV1VE6C4UwJrmEgYKwy2cr0lJCG2psh5hguxcC+CzHBuq3mbnWzLnKUyWcXDf/GwgIUjgsu8T7vEP3YSNbxezytCpjTgf9hukaH/'

  if versioncmp($puppetversion, '3.6') >= 0 {
    $purge_ssh_keys = true
  } else {
    $purge_ssh_keys = undef
  }

  user { 'test-pour-voir':
    name           => 'flaf',
    ensure         => present,
    comment        => 'Francois Lafont',
    managehome     => true,
    password       => $pwd,
    purge_ssh_keys => $purge_ssh_keys,
    shell          => '/bin/bash',
    system         => false,
    groups         => ['sudo'],
    # groups ?
    # home   ?
  }

  ssh_authorized_key { 'nick@magpie.puppetlabs.lan':
    user => 'flaf',
    type => 'ssh-rsa',
    key  => $pub_key,
  }

}


