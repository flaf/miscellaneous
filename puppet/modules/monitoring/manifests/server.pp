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

  # With additional checkpoints from Hiera, "address" and
  # "templates" keys are required with a non-empty array for
  # the "templates" value, but "custom_variables",
  # "extra_info" and "monitored" keys will have the default
  # values below if not present.
  $defaults_from_hiera = {
    'custom_variables' => [],
    'extra_info'       => {},
    'monitored'        => true,
  }

  $additional_pdbquery = $additional_checkpoints.map |$index, $checkpoint| {

    $hiera_title = "checkpoint index=${index} from Hiera via monitoring::server"

    $pdbquery = {
      'title'      => $hiera_title,
      # `certname` is Not relevant here.
      'certname'   => $::facts['networking']['fqdn'],
      # In hiera, `monitored` will be optional and the
      # default will be `true`.
      'parameters' =>  $defaults_from_hiera  + $checkpoint,
    }

    $host_conf = $pdbquery['parameters']

    unless $host_conf =~ Monitoring::HostConf {
      $host_name = $checkpoint['host_name']
      @("END"/L$).fail
        ${title}: problem with the checkpoint resource `${hiera_title}` of the \
        host_name `${host_name}` where the `address` value and/or `templates` \
        values have been probably forgotten or have the wrong type. Here is \
        the current checkpoint state: `${host_conf}`. It must match with the \
        type `Monitoring::HostConf` which is not the case currently.
        |- END
    }

    $pdbquery

  }

  $pdbquery   = puppetdb_query($query)
  $hosts_conf = ::monitoring::pdbquery2hostsconf($pdbquery + $additional_pdbquery)
                  .::monitoring::sorthostsconf

  # To debug.
  $debug = false
  if $debug {
    $pretty_array = inline_template(@(END))
      '<%- require "json" -%>
      <%= JSON.pretty_generate(@hosts_conf) %>'
    | END

    notify { 'Check of the hosts conf':
      message => "${pretty_array}",
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


