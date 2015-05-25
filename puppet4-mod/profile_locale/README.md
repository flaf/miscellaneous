# Module description

This module just sets the default locale of the system via
hiera data.

# Structure of the hiera data used by the module

In hiera, the module needs only one entry whose value must a string:

```yaml
---
default_locale: 'en_US.UTF-8'
```

That's all.


