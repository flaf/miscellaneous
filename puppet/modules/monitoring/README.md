# Module description

Module to generate Nagios-like configurations.




# Introduction: main principle of this module

The goal of this module is to generate some `host` blocks of
a Nagios-like configuration like this:

```cfg
# A host block in the Nagios-like configuration.
define host {

    # The fqdn is a good value for this parameter because
    # the "host_name" value must be unique in all the Nagios
    # configuration. The "host_name" value is like a primary
    # key of the host in the Nagios-like configurations.
    host_name srv.dom.tld

    # The address can be a fqdn or an IP address etc. This
    # is not a primary key of the host block, because it's
    # perfectly possible to have two host blocks with the
    # same address.
    address   192.168.0.252

    # The list of templates used by this Nagios host. Very
    # important because this list defines the list of checks
    # which will be applied to the host.
    use       linux_tpl,puppet_tpl,https_tpl

    # Customized variables (if needed, its depends on the
    # templates used) to configure some checks.
    #
    # Here a "simple" variable, ie its value is a string.
    _bar   xxxxxxxxxxxxxxxx
    #
    # Here an "array" variable, ie its value is an array.
    _foo   aaa, bbb, ccc
    #
    # Here a "multi-valued keys" variable, ie its value is a
    # hash where the keys are the descriptions of the check
    # and the values are parameters of the check (an arrays
    # of strings).
    _https admin-site$(srv.dom.tld/admin)$ $(pattern1)$, \
           main-site$(srv.dom.tld/)$ $(pattern2)$,

    # Some extra info, related to this host but not useful
    # in this "host" block definition. So these are just
    # comments.
    #
    # For instance, the IPMI address below will be used in
    # another block host, a dummy host to ping the IP
    # address.
    ; ipmi_address    192.168.20.252
    ; # etc...
    ; # etc...

} # End of the "host" block.
```

The main element of this module is the user-defined resource
`monitoring::host::checkpoint`. Here is a quick example
(more details about this resource type below):

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
parameters, that's all. In your puppet nodes, you can define
checkpoint resources as much as you want. **Be very careful
to define a unique title for each checkpoint resource** in
all Puppetdb. For instance, you can use this kind of title
in a class :

```puppet
class raid {

  # ...

  $fqdn = $::facts['networking']['fqdn']

  # This title Should be unique in all Puppetdb.
  monitoring::host::checkpoint {"${fqdn} from class ${title}":
    host_name => $fqdn,
    templates => ['raid_tpl'],
  }

  # ...

}
```

Then, once that all checkpoint resources are recorded in
Puppetdb (in other words once that each node of your
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

The class `monitoring::server` just:
1. collects all checkpoint resources (and especially its
   parameters) from Puppetdb,
2. makes some handles and checks of these data,
3. and then, from these data, generates the Nagios-configuration.

Two files which contains the Nagios configuration will be
generated:

* `/tmp/blacklist.conf`
* and the main file `/tmp/hosts.conf`.




# The defined type `monitoring::host::checkpoint`

This is not a class but a user-defined type. Here is an
example:

```puppet
$fqdn = $::facts['networking']['fqdn']

$custom_variables = [
  {
    # A "simple" variable.
    'varname' => '_foo',
    'value'   => 'xxx',
    'comment' => ['Very Important...', 'Blabla blabla...'],
  },
  {
    # An "array" variable.
    'varname' => '_bar',
    'value'   => ['a', 'b', 'c'],
  },
  {
    # A "multi-valued keys" variable.
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
                      "dns-${fqdn}" => {
                                         'fqdn'             => $fqdn,
                                         'expected-address' => '$HOSTADDRESS',
                                       },
                    },
}

monitoring::host::checkpoint {"base-checkpoint ${fqdn}":
  host_name        => $fqdn,
  address          => $::facts['networking']['ip'],
  templates        => ['linux_tpl*', 'https_tpl'],
  custom_variables => $custom_variables,
  extra_info       => $extra_info,
  monitored        => true,
}
```

The `host_name` parameter is the `host_name` field of the
host block (in the Nagios configuration) to which the
checkpoint resource will be related. Its default value is
`$::facts['networking']['fqdn']`. The value of this
parameter can never be `undef`.

The `address` parameter is the `address` field of the host
block (in the Nagios configuration) to which the checkpoint
resource will be related. Its default value is `undef` which
an allowed value. Indeed, for N checkpoint resource *of a
given `host_name`*, a non `undef` value for **the `address`
parameter is required on just one and only one resource**:
so you have to let the `undef` default value on N-1
checkpoint resources and set the `address` value on just 1
checkpoint resource.

The `templates` parameter allows to *add* templates on the
`host_name` block to which the checkpoint resource is
related. Its default value is `[]` ie no template is added.
For a given `host_name`, a same template can be added in a
multiple checkpoint resources. In the final configuration,
templates are sorted and duplicates are removed. It's
possible to add the trailing character `*` in a template
name (for instance `linux_tpl*`). In this case, you ensure
that this template will be on the first position (on the
left) in the host block (and the other templates will be
sorted). Of course, you can set a unique `*` template.

The `custom_variables` parameter allows to *add* customized
variables on the `host_name` block to which the checkpoint
resource is related. It default value is `[]`, ie no
customized variables are added. For a given `host_name`, the
value of a common customized variable `_foo` can be merged
**from different checkpoint resources**... under certain
conditions:

* The (string) values of a "simple" variable `_foo` can't
  be merged. So a "simple" variable `_foo` can be defined
  in only one checkpoint resource.
* The (array) values of an "array" variable `_foo` can be
  merged, the arrays of strings will be merged.
* The (hash) values of a "multi-valued keys" variable `_foo`
  can be merged but only if they haven't a common key.

See [this file](types/customvariable.pp) to have more
details concerning the type of a custom variable.

The `extra_info` parameter allows to set meta informations
which are related to the host but which will not generate
checks in the host block of this host. For instance the IPMI
address concerns the host but the check of the IPMI (a ping)
will be not defined in the host-block of the host. It will
be defined in a dedicated dummy host. It's the same for DNS
checks. The default value of this parameter is `{}` ie no
exta informations added. Currently, this hash parameter can
accept only 3 keys:

* `ipmi_address` whose its value is a string (in fact a it's
  a pattern to avoid special characters).
* `check_dns` whose the value has the type `Monitoring::CheckDns`
  (see [this file](types/checkdns.pp) to have more details).
* `blacklist` whose the value has the type `Monitoring::Blacklist`
  (see [this file](types/blacklist.pp) to have more details)

If the keys `ipmi_address` and/or `check_dns` are present, a
dummy host will be automatically created in the final Nagios
configuration to check the IPMI address and/or the DNS
record(s).

The parameter `extra_info` can be merged from different
checkpoint resources under certain conditions:

* The values of `ipmi_address` can't be merged. If defined,
  it must be defined in a only one checkpoint resource.
* The values of `check_dns` can be merged but only if the
  hashes `$extra_info['check_dns']` (from each different
  checkpoint resources) have no common key (ie no common
  service description).
* The values of `blacklist` can be merged without restriction.

In `check_dns`, the value `$HOSTADDRESS$` is possible for the
key `expected-address` and this value will be changed to the
value of the `address` parameter of the checkpoint resource.


The `monitored` parameter can be `true`, `false` or `undef`
which is the default value. If set to `false`, the
`host_name` to which the checkpoint resource is related will
be not present in the final Nagios configuration generated
by the class `monitoring::server`. Like the `address`
parameter, for a given `host_name`, the `monitored`
parameter must be set to a non `undef` value (ie `true` or
`false`) on one and only one checkpoint resource.

Remark: in a checkpoint resource, each parameter below can
be empty:

* `templates` can be equal to `[]`,
* `custom_variables` can be equal to `[]`,
* `extra_info` can be equal to `{}`.

But they can be empty simultaneously (in this case the
checkpoint resource has no sense).




# The class `monitoring::host`

This class just defines a checkpoint resource which will be
a kind of *main* checkpoint of the current host and which will
be settable via Hieradata. Here is an example:

```puppet
$fqdn = $::facts['networking']['fqdn']

$custom_variable = [
  {
    'varname' => '_https',
    'value'   => {
                  'site-main'  => ['$HOSTADDRESS$/main', 'pattern1'],
                  'site-admin' => ['$HOSTADDRESS$/admin', 'pattern2'],
                 },
  },
]

$extra_info = {
  'check_dns' => {
    "dns-${fqdn}" => {
      'fqdn'             => $fqdn,
      'expected-address' => '$HOSTADDRESS$',
    },
  },
}


class {'monitoring::host::params':
  host_name       => $fqdn,
  address         => $::facts['networking']['ip'],
  templates       => ['linux_tpl*', 'raid_tpl', 'https_tpl'],
  custom_variable => $custom_variable,
  extra_info      => $extra_info,
  monitored       => true,
}

include 'monitoring::host'
```

All the parameters of this class are exactly the parameters
of the checkpoint resource declared in this class. Details
about these parameters has been given in the section
dedicated to the custom type `monitoring::host::checkpoint`.

However, the default value of each parameter is not
necessarily the same default value of a checkpoint resource.
See [this file](functions/data.pp) to know the default value
and the default merge policy of each parameter.




# The class `monitoring::server`

This class allows to generate the final Nagios-like
configuration. Here is an example:

```puppet
$additional_checkpoints = ...
$additional_blacklist   = ...
$datacenter             = 'dc3'

class {'monitoring::server::params':
  additional_checkpoints => $additional_checkpoints,
  additional_blacklist   => $additional_blacklist,
  filter_tags            => [$datacenter],
}

include 'monitoring::server'
```

The `additional_checkpoints` parameter is an array of
`Monitoring::CheckPoint`, ie an array of structure where the
keys are exactly the parameters of a checkpoint resource:

* The key `host_name` is mandatory.
* The key `address` is mandatory too and mustn't be `undef`.
* The key `templates` is mandatory too and can't be empty.
* The keys `custom_variables`, `extra_info` and `monitored`
  can be omitted and, in this case, it's equivalent to set
  it respectively to `[]`, `{}` and `true`.

The `additional_blacklist` parameter must match with
`Monitoring::Blacklist` (see [this file](types/blacklist.pp))
except that the `host_name` key is required.

The `filter_tags` parameter is an array of strings which
allows to filter the Puppetdb collection of checkpoints by
tags. For instance, if you set a tag by datacenter, you can
generate a Nagios configuration with only hosts from a
specific datacenter with this parameter. The default value
of this parameter is `[]`, ie no filter.




