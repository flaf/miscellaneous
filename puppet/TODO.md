# Remove `$::lsbdistcodename`

```
$ rgrep lsbdist  | grep -v ^modules/apt/ | grep -v '::facts' | grep lsbdist
modules/homemade/README.md:uses the `lsbdistcodename` fact to know the distribution
modules/mcollective/manifests/server.pp:  if $::lsbdistcodename == 'trusty' {
modules/ceph/manifests/cluster/packages.pp:  if $::lsbdistcodename == 'trusty' {
modules/keyboard/manifests/init.pp:  case $::lsbdistcodename {
modules/basic_ssh/manifests/server.pp:  case $::lsbdistcodename {
modules/.deprecated/homemade/lib/puppet/parser/functions/is_supported_distrib.rb:    current_distrib = lookupvar('lsbdistcodename')
modules/network/manifests/resolv_conf.pp:    if $::lsbdistcodename == 'jessie' {
```

Update these files:
- `modules/mcollective/manifests/server.pp`
- `modules/ceph/manifests/cluster/packages.pp`
- `modules/keyboard/manifests/init.pp`
- `modules/basic_ssh/manifests/server.pp`
- `modules/network/manifests/resolv_conf.pp`


# How to generate a `checksums.json`?

Interesting because it avoids upgrade if at least one file
is changed.



