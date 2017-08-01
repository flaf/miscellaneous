class monitoring::server {

  include '::monitoring::server::params'

  [
    $filter_tags,
  ] = Class['::monitoring::server::params']

  $query = @("END"/L$)
    resources[parameters, certname] {
      type = 'Monitoring::Host::Checkpoint'
      and nodes { deactivated is null and expired is null }
    }
    |- END

  $big_array    = puppetdb_query($query)
  $pretty_array = inline_template('<%- require "json" -%> <%= JSON.pretty_generate(@big_array) %>')

  notify { 'Test':
    message => "${pretty_array}",
  }

}


