# The role `pxeserver`

This role sets a PXE server via dnsmasq.
This role includes:

- the `roles::generic` class,
- the `pxeserver` class.


## Usage

Here is an example:

```puppet
class { '::roles::pxeserver':
  no_dhcp_interfaces => [ 'eth0' ],
  backend_dns        => [ '8.8.8.8', '8.8.4.4' ],
}
```


## Parameters of `roles::pxeserver`

The parameters `no_dhcp_interfaces` and `backend_dns`
override the parameters
`pxeserver::params::no_dhcp_interfaces` and
`pxeserver::params::backend_dns` of the class
`pxeserver::params`. The default values of these parameters
are `undef`. So, in this case, the values of the parameters
`pxeserver::params::no_dhcp_interfaces` and
`pxeserver::params::backend_dns` take the precedence.




