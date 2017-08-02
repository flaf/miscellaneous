class monitoring::server {

  include '::monitoring::server::params'

  [
    $additional_checkpoints,
    $additional_blacklist,
    $filter_tags,
  ] = Class['::monitoring::server::params']

  # The puppetdb query to collect all the checkpoint resources.
  $query = inline_epp(@(END), {'tags' => $filter_tags})
    <%- |$tags| -%>
    resources[title, certname, parameters] {
      type = 'Monitoring::Host::Checkpoint'
      and nodes { deactivated is null and expired is null }
      <%- $tags.each |$a_tag| { -%>
      and tag = "<%= $a_tag %>"
      <%- } -%>
    }
    |- END

  $big_array = puppetdb_query($query)

  #$pretty_array = inline_template('<%- require "json" -%> <%= JSON.pretty_generate(@big_array) %>')
  #notify { 'Test': message => "${pretty_array}" }

  $new_array = ::monitoring::pdbquery2hostsconf($big_array)

  $pretty_new_array = inline_template('<%- require "json" -%> <%= JSON.pretty_generate(@new_array) %>')
  notify { 'Test_new': message => "${pretty_new_array}" }

}


