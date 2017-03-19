# Module description

This module just installs wget and configures HTTP proxy in
`/etc/wgetrc` if needed.

# Usage

Here is an example:

```puppet
class { '::wget::params':
  http_proxy  => 'http://httpproxy.domain.tld:3128',
  https_proxy => 'http://httpproxy.domain.tld:3128',
}

include '::wget'
```

The parameters `http_proxy` allows to set the variable
`http_proxy` in the file `/etc/wgetrc`. Its value can be:

1. A non-empty string where, in this case, `http_proxy` is
   set and equal to this string in `/etc/wgetrc`.
2. `'undefined'` which is a special string because, in this case,
   the module ensures that `http_proxy` is just undefined at all
   in `/etc/wgetrc` (the line is commented if needed).
3. `'unmanaged'` which is a special string too where, in this case,
   `http_proxy` is just unmanaged (regardless of its current value
    in the file `/etc/wgetrc`).

The default value is `'unmanaged'`.

This is exactly the same behavior with the parameter
`https_proxy`.

If `http_proxy` *and* `https_proxy` are set to `'unmanaged'`
simultaneously, the only effect of this module is to ensure
the installation of the `wget` package.


