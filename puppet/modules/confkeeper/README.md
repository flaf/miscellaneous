# TODO

* Add a parameter to add specific gitolite account which will be "all-in-one.git" readers.
* Make a completed readme file.


```puppet
exported_repos = {
  fqdn1 => {
    account      => 'root', # <= Optional, default is "root".
    ssh_pubkey   => 'xxx....xxx',
    repositories => {
      '/path/foo/bar' => {
        relapath    => 'fqdn1/path-foo-bar.git',                        # <= Opiotnal.
        permissions => [{'rights' => 'RW+', 'target' => "root@fqdn1"}], # <= Optional.
        gitignore   => [],                                              # <= Optional.
      }
      # ...
    }
  }
  # ...

}
```

# Module description

Module to export configurations in a server




# Usage

Here is an example:

```puppet
class { '::confkeeper':
  # ...
}
```




# Parameters

TODO...


