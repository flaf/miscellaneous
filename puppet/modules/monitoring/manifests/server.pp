class monitoring::server {

  include '::monitoring::server::params'

  [
    $additional_checkpoints,
    $additional_blacklist,
    $filter_tags,
  ] = Class['::monitoring::server::params']

  $additional_blacklist.each |$index, $rule| {
    if $rule.dig('host_name') =~ Undef {
      @("END"/L$).fail
        ${title}: problem with the `additional_blacklist` parameter in Hiera \
        where the `host_name` field is not defined in the rule index number \
        ${index} (at least). This is not allowed.
        |- END
    }
  }

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

  $additional_pdbquery = $additional_checkpoints.map |$index, $checkpoint| {
    {
      'title'      => "checkpoint ${index} from Hiera via monitoring::server",
      # `certname` is Not relevant here.
      'certname'   => $::facts['networking']['fqdn'],
      # In hiera, `monitored` will be optional and the
      # default will be `true`.
      'parameters' =>  {'monitored' => true} + $checkpoint,
    }
  }

  $pdbquery   = puppetdb_query($query)
  $hosts_conf = ::monitoring::pdbquery2hostsconf($pdbquery + $additional_pdbquery)

  # To debug.
  #
  #$pretty_array = inline_template(@(END))
  #  '<%- require "json" -%>
  #  <%= JSON.pretty_generate(@hosts_conf) %>'
  #| END
  #
  #notify { 'Check of the hosts conf':
  #  message => "${pretty_array}",
  #}

  $all_ipmi_addresses = $hosts_conf.reduce({}) |$memo, $host| {
    $ipmi = $host.dig('extra_info', 'ipmi_address')
    if $ipmi =~ Undef {
      $memo
    } else {
      $memo + {$host['host_name'] => $ipmi}
    }
  }

  file {
    default:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
    ;

    '/tmp/hosts.conf':
      content => epp(
                   'monitoring/hosts.conf.epp',
                   {
                    'hosts_conf' => $hosts_conf,
                    'ipmis'      => $all_ipmi_addresses,
                   },
                 ),
    ;

    '/tmp/blacklist.conf':
      content => epp(
                   'monitoring/blacklist.conf.epp',
                   {
                    'hosts_conf'           => $hosts_conf,
                    'additional_blacklist' => $additional_blacklist,
                   },
                 ),
    ;
  }

}


