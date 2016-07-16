# The role `moobotnode`

This role allows to install:
- a cargo server,
- a captain server,
- or a lb (haproxy load balancer) server.


## Usage

Here is an example:

```puppet
class { '::roles::moobotnode::params':
  nodetype => 'cargo'
}

include '::roles::moobotnode'
```


## Parameter

The parameter `nodetype` is the only parameter of the
class `roles::moobotnode::params` and its value must
match with `Enum[ 'cargo', 'lb', 'captain' ]`.


