TODO: Please, make a real README file...

# Module description

Module to manage a HTTP proxy.

# How to retrieve the content of PGP public key

```sh
ID='6F6B15509CF8E59E6E469F327F438280EF8D349F'
dir=$(mktemp -d)
gpg --keyserver hkp://keyserver.ubuntu.com:80 --no-default-keyring --keyring "$dir/f1" --recv-keys "0x${ID}"

# Print the key on STDOUT.
gpg --armor --no-default-keyring --keyring "$dir/f1" --export "0x${ID}"

# Put the key in a file.
gpg --output pubkey.gpg --armor --no-default-keyring --keyring "$dir/f1" --export "0x${ID}"

# Cleaning.
rm -r "$dir"
```


# Usage

Here is an example:

```puppet
class { '::httpproxy':
  # ...
}
```




# Parameters

TODO...


