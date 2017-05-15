class httpproxy::params (
  Boolean                        $enable_apt_cacher_ng,
  Optional[String[1]]            $apt_cacher_ng_adminpwd,
  Integer[1]                     $apt_cacher_ng_port,
  #
  Boolean                        $enable_keyserver,
  String[1]                      $keyserver_fqdn,
  Array[Httpproxy::PGPPublicKey] $pgp_pubkeys,
  #
  Boolean                        $enable_puppetforgeapi,
  String[1]                      $puppetforgeapi_fqdn,
  #
  Boolean                        $enable_squidguard,
  Array[String[1]]               $squid_allowed_networks,
  Integer[1]                     $squid_port,
  Httpproxy::SquidguardConf      $squidguard_conf,
  String[1]                      $squidguard_admin_email,
  #
  Array[String[1], 1]            $supported_distributions,
) {

  # Used in several places in this modules.
  $keydir       = '/var/www/html/key'
  $forbiddendir = '/var/www/html/forbidden'


  ### Additional checks about the parameter $pgp_pubkeys. ###

  # Check that each "name" _and_ each "id" are unique.
  $pgp_pubkeys.reduce({'names' => [], 'ids' => []}) |$memo, $pubkey| {

    $name = $pubkey['name']
    $id   = $pubkey['id']

    if $name in $memo['names'] {
      @("END"/L).fail
        ${title}: sorry, the parameter `httpproxy::params::pgp_pubkeys` \
        has two keys with the same name "${name}" which is forbidden.
        |-END
    }

    if $id in $memo['ids'] {
      @("END"/L).fail
        ${title}: sorry, the parameter `httpproxy::params::pgp_pubkeys` \
        has two keys with the same ID "${id}" which is forbidden.
        |-END
    };

    {'names' => ($memo['names'] + $name), 'ids' => ($memo['ids'] + $id)}

  }

  # Deprecated: a Httpproxy::PGPPublicKey data type will
  #             have only the 'content' key.
  #
  # Check that exactly only one key among ['keyserver',
  # 'url', 'content'] is present on each PGP public key.
  #$pgp_pubkeys.each |$pubkey| {
  #  $n = $pubkey.reduce(0) |$memo, $v| {
  #    case ($v[0] in ['keyserver', 'url', 'content']) {
  #      true:    { $memo + 1 }
  #      default: { $memo     }
  #    }
  #  }
  #  unless $n == 1 {
  #    $name = $pubkey['name']
  #    @("END"/L).fail
  #      ${title}: sorry, in the parameter `httpproxy::params::pgp_pubkeys` \
  #      the key "${name}" must be a hash with exactly one key among \
  #      ['keyserver', 'url', 'content'], here ${n} key(s) found.
  #      |-END
  #  }
  #}

}


