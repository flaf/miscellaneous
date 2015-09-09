* A module to manage `/etc/hosts`.
* A module to manage `/etc/resolv.conf` and `unbound`.
* Bug with the `metadata.json` file (https://tickets.puppetlabs.com/browse/PUP-5209).
* A module to manage ntp.
* A module to manage users. Something to just manage
admins accounts (`pwd`, `is_sudo`, bash configuration) and remove it if
they exist no longer.

Now:
 0. ntp
 1. puppetagent
 2. puppetserver
 3. mcollective


