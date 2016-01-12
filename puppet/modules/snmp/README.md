# Module description

Basic module to just install and configure snmpd.


# Typical example of yaml file

```yaml
snmp:
  views: # optional with this default value.
    monitoring: [ '.1.3.6.1.2.1', '.1.3.6.1.4.1' ]
  snmpv3_accounts:
    shinkendc2:
      authproto: 'sha' # optional and default is 'sha'
      authpass: 'xxxxxxxxxxxxxxxxxxxxx'
      privproto: 'aes' # optional and default is 'aes'
      privpass: 'YYYYYYYYYYYYYYYYYYYYYY'
      view: 'monitoring' # optional and default is 'monitorng'
  communities:
    toto45:
      - source: 'localhost'
        view: 'monitoring' # optional and default is 'monitorng'
      - source: '172.31.0.182'
        view: 'monitoring' # optional and default is 'monitorng'
```


# TODO

* Write this readme file.
* A puppet bug (PUG 5209) make it's impossible to use
the function `::network::get_param()` in the `data()`
function of this module.


