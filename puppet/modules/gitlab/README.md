# Module description

This module installs and configures a Gitlab server.


# Usage

Here is an example:

```puppet
$fqdn = $::facts['networking']['fqdn']

$ldap_conf = {
  host                          => 'ldap.domain.tld'
  port                          => 636
  uid                           => 'uid'
  method                        => 'ssl'
  bind_dn                       => 'uid=gitlab,ou=system,dc=domain,dc=tld'
  password                      => 'xxxxxxxxxxxxxxxxxxxxxxxxx'
  allow_username_or_email_login => true
  block_auto_created_users      => false
  base                          => 'ou=people,dc=domain,dc=tld'
}

class { '::gitlab::params':
  external_url        => "http://${fqdn}",
  ldap_conf           => $ldap_conf,
  backup_retention    => 10,
  backup_cron_wrapper => '',
  backup_cron_hour    => 3,
  backup_cron_minute  => 0,
}

include '::gitlab'
```


# Parameters

The `external_url` parameter sets the `external_url` option
in the `/etc/gitlab/gitlab.rb` configuration file. The
default value of this parameter is `$::facts['networking']['fqdn']`.

The `ldap_conf` parameter allows LDAP authentication and sets
the `gitlab_rails['ldap_servers']` option in the
`/etc/gitlab/gitlab.rb` configuration file. This parameter:

- must have the structure in the example above;
- or must be equal to `'none'` which is the default value.

If this parameter is set to `'none'`, there is no LDAP
configuration and only "local" authentication is possible.

**Note:** the module sets a cron task (in the root crontab)
to backup the GitLab every day in the `/localbackup`
directory. These backups are **local** to the GitLab server.

The `backup_retention` sets the retention of the backups.
Every day, all local backups older than `backup_retention`
**days** are removed. The default value of this parameter
is `10`.

The `backup_cron_wrapper` parameter allows to add a wrapper
command in the command of the backup cron. It can be useful
if you want, for instance, add a command to monitor que
backup cron (and for instance check the return value).

The parameters `backup_cron_hour` and `backup_cron_minute`
allow to set the hour when the backup cron is launched.
The default values are respectively `3` and `0`, ie the
backup cron is launched every day at 3:00 AM by default.


# How to trigger a manual backup?

You have to use the command `gitlab-backup.puppet` (as root):

```sh
sudo gitlab-backup.puppet
```


# How to restore a local backup?

**Warning:** the restore process removes all data and all
configurations of your GitLab server. If needed, make a
manual backup before the restore.

**Remark:** if it's a new server, first you have to install
the server via a Puppet run and then you have to populate
the `/localbackup/` directory with some backups following a
tree like below (see the `tree` command).

You have to use the `gitlab-restore.puppet` command as root.
Here is an example:

```sh
# First, you have to choose the timestamp of the backup.
~$ sudo tree /localbackup/
/localbackup/
├── 2016-09-14-03h00-19
│   ├── 1473814819_gitlab_backup.tar.gz
│   └── etcgitlab.tar.gz
├── 2016-09-14-12h40-09
│   ├── 1473849609_gitlab_backup.tar.gz
│   └── etcgitlab.tar.gz
├── 2016-09-14-12h51-19
│   ├── 1473850278_gitlab_backup.tar.gz
│   └── etcgitlab.tar.gz
├── 2016-09-14-19h41-02
│   ├── 1473874862_gitlab_backup.tar.gz
│   └── etcgitlab.tar.gz
└── 2016-09-16-03h00-23
    ├── 1473987623_gitlab_backup.tar.gz # <== We choose this backup.
    └── etcgitlab.tar.gz                #     with the timestamp 1473987623

# To achieve the restore process, you have to answer "yes"
# to each question.
~$ sudo gitlab-restore.puppet '1473987623'
```

Normally, it's not required but it's probably better to
reboot the server.


# The first install (where there is no backup to restore)

After the first Puppet run, you have to visit the home page
of the server and set the password of the local `root`
account, which will be the local administrator account of
GitLab.

With the `root` account, go to `Profile Settings` and update
the `Email` field. **Warning**, this address must be unique
(just unique as string, because GitLab is unable to see if
2 different addresses are equivalent or not). For instance,
it can't be the same address as the address of a LDAP
account.

With the `root` account, go to `Admin Area` => `Settings`
(in the cogwheel) and uncheck the box of the option `Sign-up
enabled`. Don't forget to save.

With the `root` account, go to `Admin Area` => `Appearance`
(in the cogwheel) and in this page:

* Set `Danelab Git Repository` in the field `Title`.
* Put this content (this is markdown) in the field `Description`:

```
The Gitlab repository of *Dane* from Versailles (France)

*Dane* is [Délégation Académique au Numérique Éducatif](http://www.dane.ac-versailles.fr)
```

* Put this [logo](pictures/danelab.png) in the field `Logo`.
* Put this [picture](pictures/dane.png) in the field `Header logo`.

Don't forget to save.


