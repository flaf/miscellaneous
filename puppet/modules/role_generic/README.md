# Module description

This module just sets a basic and generic configuration.
This module is just a role, so see its code to have the list
of included modules.


# Usage

Here is examples:

```puppet
# To just install the ssh client.
include '::role_generic'

# To exclude some classes which will be not applied.
class { '::role_generic':
  excluded_classes => [ '::network', '::network::hosts' ]
}
```

The class `::role_generic` has just one parameter
`excluded_classes` which must be an array of non-empty
strings. The default value of this parameter is `[]`
(an empty array), ie all classes in `::role_generic`
are included and applied (no exception). If you want
to exclude a class:

* you *must* provide its absolute name beginning with `::`,
* and the class *must* be in the list of classes included
by default by `::role_generic`.

If these conditions are not satisfied, there will be
an error and just no class will be applied.

You can use hiera to provide the `excluded_classes` parameter,
ie you can just make a `include '::role_generic'` in Puppet
and put in the hiera yaml file of your node:

```yaml
role_generic::excluded_classes: [ '::network', '::network::hosts' ]
```


