# Module description

Basic module to just install and configure a replica set
mongodb cluster.


# Usage

Here is an example:

```puppet
# To have a valid content, run in a shell:
#
#    openssl rand -base64 741
#
$keyfile = 'zrzjt+Hru84PqYnI...44XLH3Ju'

# The structure is:
#
#   {
#     'base-name-a' => [ $account-a1, $account-a2 ],
#     'base-name-b' => [ $account-b1, $account-b2, $account-b3 ],
#   }
#
# where a account has this structure:
#
#   {
#     'user'     => 'toto1',
#     'password' => '123456',
#     'roles'    => [ 'roleA', 'roleB' ],
#   }
#
$databases = {
  'admin' => [
    { 'user'     => 'admin',
      'password' => '123456',
      'roles'    => [ 'userAdminAnyDatabase',
                      'readWriteAnyDatabase',
                      'dbAdminAnyDatabase',
                      'clusterAdmin'
                    ],
    },
  ]
}

class { '::mongodb::params':
  bind_ip    => [ '0.0.0.0' ],
  port       => 27017,
  auth       => true,
  replset    => 'mongo',
  smallfiles => true,
  keyfile    => $keyfile,
  quiet      => true,
  log_level  => 0,
  logpath    => '/dev/null'
  databases  => $databases,
}

include '::mongodb'
```




# Parameters

The parameter `bind_ip` is an array (of strings) of IP
addresses on which the mongodb service is going to listen.
The default value of this parameter is `[ '0.0.0.0' ]` which
means that the mongodb service will listen to any interface.

The parameter `port` is a integer which set the port on
which the mongodb listen. The default value is 27017.

The parameter `auth` is a boolean to turn on/off security.
If set to `false`, which is the default value, there is no
authentication and everybody (in the same network) can
connect to the mongodb cluster.

The parameter `replset` is the replicaset of the mongodb
cluster. Its default value is `mongo-${::domain}`.

The parameter `smallfiles` is a boolean to set the
`smallfiles` parameter in the file `/etc/mongodb.conf`.
Its default value is `true`.

The parameter `keyfile` is a string which gives the content
of the shared keyfile used by the mongodb servers of the
cluster for internal authentication (needed only when
authentication is enabled). You can generate a valid content
of this parameter via the shell command `openssl rand
-base64 741`
(see [here](https://docs.mongodb.org/manual/tutorial/enable-internal-authentication/)).
The default value of this parameter is `undef`. If the
parameter `auth` is set to `false`, the parameter `keyfile`
is not required but it is required when `auth` is `true`.

The parameter `quiet` is a boolean. If set to `true`, the
line `setParameter = quiet=true` is added in the file
`/etc/mongodb.conf`.

The parameter `log_level` is an integer to set the line
`setParameter = logLevel=$log_level` in the file
`/etc/mongodb.conf`.

The parameter `logpath` is a string but only 2 values are
accepted: `'/var/log/mongodb/mongodb.log'`, the default
value, or `'/dev/null'`. If set to `'/dev/null'`, there is
no log at all. It can be interesting because mongodb is a
little verbose, even with `logLevel=0` and `quiet=true` in
`setParameter`.

The parameter `databases` is a hash where keys are the
database names and values are arrays of mongodb accounts
(see above for the structure of this parameter). In fact,
this parameter just helps to define the file
`/root/create-dbs-users.js` which will allow to create,
manually but easily, the databases and the accounts via the
mongo shell (see below for more details). The default value
of this file is `{}`. In the parameter `databases`, the
first database and the first user in this database are
special: indeed Puppet will generate a file
`/root/.mongorc.js` so that after the simple command `mongo`
(as root), you are automatically connected in this base with
this first user.





# Manual configuration post puppet run

We handle the case where `auth=true` which the most complex.
Even if this is not the same version of mongo in Trusty,
[this page](https://docs.mongodb.org/manual/tutorial/enable-internal-authentication/)
explains some interesting concepts.

**Warning:** if you set `auth` to `true`, it's interesting
to be aware about
[this](https://docs.mongodb.org/v2.4/reference/configuration-options/#auth):

```
auth

    Default: false

    Set to true to enable database authentication for users
    connecting from remote hosts. Configure users via the
    mongo shell. If no users exist, the localhost interface
    will continue to have access to the database until you
    create the first user.
```

We can create users only on the PRIMARY server. So, First
time on the (expected to be) PRIMARY server (and ONLY on ONE
server):

```sh
# The option --norc is present to ignore the file
# /root/.mongorc.js which allows to be connected directly
# with the admin user in the admin base (like a .my.cnf
# file). But, at this moment, the user doesn't exist yet.
~# mongo --norc
MongoDB shell version: 2.4.9
connecting to: test
> rs.initiate()

# Or directly in the shell bash:
#
#       echo 'rs.initiate()' | mongo --norc
#
```

Then, wait 1 minute until you have this prompt:

```sh
~# mongo --norc
MongoDB shell version: 2.4.9
connecting to: test
moogo:PRIMARY> 
```

Now, always in the primary server, you can create databases
and users with this:

```sh
mongo --norc <create-dbs-users.js
```

**Warning:** you have to define at least a user with the
roles `userAdminAnyDatabase` and `clusterAdmin` to be able
to have a replica set UP.

Now, you have to authenticate in mongo before to create the
replica set. So manually add the replicatset members like this:

```sh
~# mongo
MongoDB shell version: 2.4.9 connecting to: test
MongoDB shell version: 2.4.9
connecting to: test

### Begin (should be not necessary) ###
#
# Normally, with the .mongorc.js file generated by Puppet,
# you don't need to input manually the admin password etc.
# and you should be admin directly after the simple `mongo`
# command.
#
> use admin # use the database where the user has been created.
switched to db admin

> db.auth('admin', 'xxxxxxxxxxxxx')
1
### End ###

# Add members.
moogo:PRIMARY> rs.add("moogo02")
{ "ok" : 1 }
moogo:PRIMARY> rs.add("moogo03")
{ "ok" : 1 }
moogo:PRIMARY> 
```

And check that everything is fine:

```sh
moogo:PRIMARY> rs.status() # Check the "health" value (should be 1) in the "members" array
moogo:PRIMARY> show dbs
moogo:PRIMARY> show users
```

And you can check on the non-primary mongos that you have this
(be careful, you have to authenticate in the non-primary
nodes too):

```sh
~# mongo
MongoDB shell version: 2.4.9
connecting to: test

### Begin (should be not necessary) ###
> use admin
switched to db admin
> db.auth('admin', 'xxxxxxxxxxxxx')
1
### End ###

moogo:SECONDARY> 
```

It's possible to set the priority for each node. It's a
simple weight (from 0 to 1000), so the absolute value is not
relevant at all... except when equal to 0: in this specific
case, a node will be **never** the PRIMARY. You must run
these commands on the PRIMARY node:

```sh
# Assign the replica set configuration in a variable.
moogo:PRIMARY> cfg = rs.conf()

# Set the priority as you want. Be careful, in
# "cfg.members[0]" 0 is the index of a element in the
# cfg.members array and this is not automatically to the
# value of the "_id" entry.
moogo:PRIMARY> cfg.members[0].priority = 1
moogo:PRIMARY> cfg.members[1].priority = 1
moogo:PRIMARY> cfg.members[2].priority = 0.5

# To see the new configuration, not yet pushed. In a member,
# if the priority is equal to 1, it will not be displayed
# because 1 is the default value of the priority.
moogo:PRIMARY> cfg

# Now, we apply the new configuration. Maybe it can
# trigger a new election of the PRIMARY node.
moogo:PRIMARY> rs.reconfig(cfg)
```

It's possible to connect to mongo directly with a specific
user on a specific base on a specific host. For instance:

```sh
mongo $base -u admin -p 'xxxxxxxxxxxxx' --host moogo02
```



To have the status of the mongodb replica set, you can launch:

```sh
echo $'use admin\ndb.runCommand( { replSetGetStatus : 1 } )' | mongo
```


