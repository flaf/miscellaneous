# The role `confkeeper`

This role install a confkeeper server, ie
a collector of configurations.


## Usage

Here is an example:

```puppet
class { '::roles::confkeeper':
  no_provider => false,
}
```

The default value of the parameter `no_provider` is `false`.
If this is the first time of the puppet run, there is no
collector server (the collector will be UP after this first
puppet run), so you have to install first the collector
without the "provider" installation part. So you have to set
this parameter to `true` for the first puppet run only.


