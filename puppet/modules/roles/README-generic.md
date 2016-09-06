# The role `generic`

This role just sets a basic and generic configuration.


## Usage

Here is examples:

```puppet
# 1. Problably all the classes will be included (see below).
include '::roles::generic'

# 2. To exclude some classes which will be not applied.
class { '::roles::generic::params':
  excluded_classes => [ '::network', '::network::hosts' ]
}
include '::roles::generic'

# 3. To include only some classes explicitely.
class { '::roles::generic::params':
  included_classes => [ '::network' ]
}
include '::roles::generic'
```




## The parameters of `roles::generic::params`


The `authorized_classes` parameter is an array of classes
that the module can potentially apply. The module can apply
no class except the classes in this array. See the code of
the module to know the (hardcoded) default value of this
parameter. Normally, you should never set this parameter and
always keep its default value.

The `excluded_classes` parameter must be an array of
non-empty strings. The default value of this parameter is
`[]` (no class is excluded) unless the node is a Proxmox
server (determined via the custom fact `$::is_proxmox`).
In this case, the default value is `[ '::network::hosts' ]`.
If you want to exclude a class:

* you *must* provide its absolute name beginning with `::`,
* and the class *must* be in the list of `authorized_classes`.

If at least one of these conditions is not satisfied, there
will be an error during the catalog compilation.

The `included_classes` parameter must be an array of
non-empty strings. The default value of this parameter is
approximatively the value of the parameter `authorized_classes`
(see the code for more details). The classes in
`included_classes` *must* be in the list of
`authorized_classes`.

**Note:** finally the classes applied by the node are always
`$included_classes - $excluded_classes`.



