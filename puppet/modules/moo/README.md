# Module description

This module implements the management of:

- cargo servers,
- lb server,
- captain server

in a moodle plateform.


# Post-installation in captain

After the puppet run, you have to initialize the database
via the command (as root):

```sh
mysql -u root -h localhost --password='' < init-moobot-database.sql
```


# Usage

TODO: write the README, especially for `moo::cargo`
(complex data binding).


