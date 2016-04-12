# Module description

Basic module to just install and configure the snmp service.




# Usage

Here is a typical example:

```yaml
snmp::params::views:
  monitoring: [ '.1.3.6.1.2.1', '.1.3.6.1.4.1' ]

snmp::params::snmpv3_accounts:
  shinken:
    name: 'azerty'
    authproto: 'sha' # optional and default is 'sha'
    authpass: 'xxxxxxxxxxxxxxxxxxxxx'
    privproto: 'aes' # optional and default is 'aes'
    privpass: 'YYYYYYYYYYYYYYYYYYYYYY'
    view: 'monitoring' # optional and default is 'monitoring'
  test:
    name: 'security'
    authproto: 'sha'
    authpass: 'xxxxxxxxxxxxxxxxxxxxx'
    privproto: 'aes'
    privpass: 'YYYYYYYYYYYYYYYYYYYYYY'
    view: 'monitoring'

snmp::params::communities:
  jrds:
    name: 'xxxx'
    access:
      - source: 'localhost'
        view: 'monitoring' # optional and default is 'monitorng'
      - source: '172.31.0.182'
        view: 'monitoring' # optional and default is 'monitorng'
  jrds2:
    name: 'yyy'
    access:
      - source: '172.30.240.182'
        view: 'monitoring'
```

With this yaml configuration, you can just include the
class: `include '::snmp'`.




# Parameters of `snmp::params`

The `interface` parameter is the IP address used by the SNMP
service. The special value `'all'` means that the service
will listen to all addresses. The default value of this
parameter is `$::facts['networking']['ip']`. So, for
instance, if the host has only one interface with just one
IP address, this address will be the default value of this
parameter.

The `port` parameter is the UDP port used by the SNMP
service. It's an integer and its default value is `161`.

The `syslocation` and `syscontact` parameters are the values
of the same instructions in the `snmpd.conf` file. The
default value of `syslocation` is `$::datacenter` is the
variable is defined, else it's `$::domain`. The default
value of `syscontact` is `"admin@${::domain}"`.

The `snmpv3_accounts` parameter must have the structure
above. It's a hash where each value is a SNMPv3 account.
The default value of this parameter is `{}`, ie no SNMPv3
account at all.

The `communities` parameter must have the structure
above. It's a hash where each value is a community.
The default value of this parameter is `{}`, ie no
community at all.

The `views` parameter is a hash where a key is the
name of a view and the value is an array of OID.

**Warning:** the default merging policy for the parameters
`snmpv3_accounts`, `communities` and `views` is `deep`.




