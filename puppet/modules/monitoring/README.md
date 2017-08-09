TODO: Please, make a real README file...

# Module description

Module to generate Nagios-like configurations.


# Introduction: main principle of this module

The goal of this module is to generate, some `host`
Nagios-like configurations like this:

```cfg
# A host in the Nagios-like configuration.
define host {

    # The hostname of in the Nagios configuration. The fqdn
    # is a good value because the "host_name" value must be
    # unique in all the Nagios configuration.
    host_name srv.dom.tld

    # The address can be a fqdn or an IP address etc.
    address   192.168.0.252

    # The list of templates used by this Nagios host. Very
    # important because to define the checks which will be
    # applied to the host.
    use       linux_tpl,puppet_tpl,https_tpl

    # Customized variables (if needed, its depends on the
    # templates used) to configure some checks.
    #
    # Here a "simple variable" where the value is a string.
    _bar   xxxxxxxxxxxxxxxx
    #
    # Here an "array variable".
    _foo   aaa, bbb, ccc
    #
    # Here a "multi-valued key variable" where the value
    # is a hash where the keys are the descriptions and
    # the values are arrays of strings.
    _https admin-site$(srv.dom.tld/admin)$ $(pattern1)$, \
           main-site$(srv.dom.tld/)$ $(pattern2)$,

    # Some extra info, related to this host but not
    # useful the this "host" bloc definition.
    #
    ; ipmi_address    192.168.20.252
    ; # etc...
    ; # etc...

} # End of the "host" bloc.
```

The main element of this module is the user-defined resource
`monitoring::host::checkpoint`. Here is an example (more
details about this resource type below):

```puppet
$fqdn = $::facts['networking']['fqdn']

monitoring::host::checkpoint {"base-checkpoint ${fqdn}":
  host_name        => $fqdn,
  address          => $::facts['networking']['ip'],
  templates        => ['linux_tpl', 'puppet_tpl'],
  custom_variables => [],
  extra_info       => {},
  monitored        => true,
}
```

A checkpoint resource **does nothing, manages no resource**
etc. It's just an empty user-defined resource (like an empty
shell) which will be **recorded in the Puppetdb** with its
parameters, that's all.

In your puppet nodes, you can define checkpoint resources as
much as you want. **Be very careful to define unique titles
for each checkpoint resource** in all the Puppetdb. For
instance, you can use this kind of title in a class :

```puppet
class raid {

  # ...

  $fqdn = $::facts['networking']['fqdn']

  # This title Should be unique in all Puppet.
  monitoring::host::checkpoint {"${fqdn} from class ${title}":
    host_name => $fqdn,
    templates => ['raid_tpl'],
  }

  # ...

}
```

Then, once that all checkpoint resources are recorded in
Puppetdb (in other words once that each node of you
infrastructure has made its puppet run), you can generate
all the Nagios configuration **on the puppetserver** with:

```sh
puppet apply -e 'include monitoring::server' --show_diff

# Or better:
mkdir -p ~/facts.d/

cat >~/facts.d/enc.sh <<'EOF'
#!/bin/sh

/etc/puppetlabs/code/environments/enc "$FQDN" | jq -r '.["parameters"]'
EOF

chmod u+x ~/facts.d/enc.sh

export FQDN=$(hostname -f)
puppet apply -e 'include monitoring::server' --pluginfactdest=~/facts.d/ --show_diff
```

Then 2 files which contains the Nagios configuration
will be generated:

* `/tmp/blacklist.conf`.
* `/tmp/hosts.conf`, the main file.




# The defined type `monitoring::host::checkpoint`

This is not a class but a user-defined type. Here is an
example:

```puppet
$fqdn = $::facts['networking']['fqdn']

$custom_variables = [
  {
    'varname' => '_foo',
    'value'   => 'xxx',
  },
  {
    'varname' => '_bar',
    'value'   => ['a', 'b', 'c'],
  },
  {
    'varname' => '_https',
    'value'   => {
                  'main-site'  => ["${fqdn}/main/", "pattern1"],
                  'admin-site' => ["${fqdn}/admin/", "pattern2"],
                 },
  },
]

$extra_info = {
  'ipmi_address' => '192.168.20.14',
  'check_dns'    => {
                      'fqdn'             => $fqdn,
                      'expected-address' => '$HOSTADDRESS',
                    },
}

monitoring::host::checkpoint {"base-checkpoint ${fqdn}":
  host_name        => $fqdn,
  address          => $::facts['networking']['ip'],
  templates        => ['linux_tpl', 'https_tpl'],
  custom_variables => $custom_variables,
  extra_info       => $extra_info,
  monitored        => true,
}
```

The `host_name` parameter is the `host_name` field of the
host bloc (in the Nagios configuration) to which the
checkpoint resource will be related. Its default value is
`$::facts['networking']['fqdn']`. The value of this
parameter can never be `undef`.

The `address` parameter is the `address` field of the host
bloc (in the Nagios configuration) to which the checkpoint
resource will be related. Its default value is `undef` which
an allowed value. Indeed, for N checkpoint resource *of a
given `host_name`*, a non `undef` value for **the `address`
parameter is required on just one and only one resource**:
so you have to let the `undef` default value on N-1
checkpoint resources and set the `address` value on just 1
checkpoint resource.

The `templates` parameter allows to *add* templates on the
`host_name` bloc to which the checkpoint resource is related.


The `monitored` parameter can be `true`, `false` or `undef`
which is the default value. If set to `false`, the
`host_name` to which the checkpoint resource is related will
be not present in the final Nagios configuration generated
by the class `monitoring::server`. Like the `address`
parameter, for a given `host_name`, the `monitored`
parameter must be set to a non `undef` value (ie `true` or
`false`) on one and only one checkpoint resource.


# Parameters

TODO...


