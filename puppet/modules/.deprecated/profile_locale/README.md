# Module description

This module just sets the default locale of the system via
hiera data.

# Structure of the hiera data used by the module

In hiera, the module needs only one entry whose value must a string:

```yaml
default_locale: 'en_US.UTF-8'
```

Be careful, the module is set by default with the `basis` stage
parameter which must be defined before.


