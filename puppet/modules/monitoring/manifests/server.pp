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
    resources[title, parameters] {
      type = 'Monitoring::Host::Checkpoint'
      and nodes { deactivated is null and expired is null }
      <%- $tags.each |$a_tag| { -%>
      and tag = "<%= $a_tag %>"
      <%- } -%>
    }
    |- END

  $big_array = puppetdb_query($query)

  $pretty_array = inline_template('<%- require "json" -%> <%= JSON.pretty_generate(@big_array) %>')
  notify { 'Test': message => "${pretty_array}" }

  $host2address = $big_array.reduce({}) |$memo, $checkpoint| {

    $host_name = $checkpoint['parameters']['host_name']
    $address   = $checkpoint['parameters'].dig('address')

    case [$host_name in $memo, $address =~ Undef] {
      [false, default]: { $memo + {$host_name => $address} }
      [true, true]:  { $memo }
      [true, false]: {
        $old_address = $memo[$host_name]['address']
        if $old_address == $address {
          $memo
        } else {
          @("END"/L$).fail
            ${title}: sorry there are 2 `checkpoints` resources collected \
             with the host `${host_name}` but with a different \
             address: ${old_address} and ${address}. This is not allowed.
            |- END
        }
      }
    }

  }

  $host2address.each |$host_name, $address| {
    if $address =~ Undef {
      @("END"/L$).fail
        ${title}: sorry the host `${host_name}` has no address in any \
        `checkpoints` resources collected. This is not allowed.
        |- END
    }
  }

}


