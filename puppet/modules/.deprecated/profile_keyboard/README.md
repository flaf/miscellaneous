# Module description

Module to set the keyboard configuration via hiera data.

# Structure of the hiera data used by the module

Here is the needed data:

```yaml
keyboard:
  xkbmodel: 'pc105'
  xkblayout: 'fr'
  xkbvariant: 'latin9'
```

Be careful, the module is set by default with the `basis` stage
parameter which must be defined before.


