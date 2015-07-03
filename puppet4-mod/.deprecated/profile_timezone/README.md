# Module description

This module sets the timezone of the system via hiera data.

# Structure of the hiera data used by the module

In hiera, the module needs only one entry whose value must a string:

```yaml
timezone: 'Europe/Paris'
```

Be careful, the module is set by default with the `basis` stage
parameter which must be defined before.


