class samba4::member::config {

  require 'samba4::common::params'
  require 'samba4::member::params'

  $realm        = $samba4::common::params::realm
  $workgroup    = $samba4::common::params::workgroup
  $netbios_name = $samba4::common::params::netbios_name
  $ip_dc        = $samba4::member::params::ip_dc

  file { 'resolv.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    path    => '/etc/resolv.conf',
    content => "domain $domain\nsearch $domain\nnameserver $ip_dc\n\n",
  }

  file { 'smb.conf':
    require => File['resolv.conf'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    path    => '/etc/samba/smb.conf',
    content => template('samba4/member_smb.conf.erb'),
  }

# Une jonction (enfin quand ça marchera...) :
#   samba-tool domain join athome.priv MEMBER -U administrator%admin
#   ou --> net ads join -U administrator%admin
#
# Lister tous les enregistrements DNS de tout type et de type A seulement :
#   samba-tool dns query localhost athome.priv @ ALL -U administrator%admin
#   samba-tool dns query localhost athome.priv @ A   -U administrator%admin
#
# Suppression de l'enregistrement DNS de type A « samba.athome.priv -> 172.31.5.2 » :
#   samba-tool dns delete localhost athome.priv samba A 172.31.5.2 -U administrator%admin
#
# Création d'une entrée DNS (celle qui a été supprimée ci-dessus) :
#   samba-tool dns add localhost athome.priv samba A 172.31.5.2 -U administrator%admin
#
# Vérifier tous les paramètres de smb.conf :
#   samba-tool testparm --suppress-prompt
#
# Changer le mot de passe du compte administrator :
#   samba-tool user setpassword administrator --newpassword="admin"
#
# Pour sortir du domaine ke serveur sur lequel on est connecté :
#   net ads leave -U administrator%admin

}


