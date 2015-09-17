class role_generic {

  include '::network'
  include '::repository::distrib'
  include '::basic_ssh::server'
  include '::basic_ssh::client'
  include '::keyboard'
  include '::locale'
  include '::timezone'
  include '::ntp'
  include '::puppetagent'
  include '::mcollective::server'

  if $::fqdn =~ /^puppet/ {
    include '::mcollective::client'
  }

  if $::fqdn =~ /^client-jessie\./ {
    include '::puppet_forge'
  }

}


