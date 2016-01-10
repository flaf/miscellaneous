# Module description

Basic module to just install and configure mongodb.

# Post puppet run

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
~# mongo
MongoDB shell version: 2.4.9
connecting to: test
> rs.initiate()

# Or directly in the shell bash:
#
#       echo 'rs.initiate()' | mongo
#
```

Then wait 1 minute until you have this prompt:

```sh
~# mongo
MongoDB shell version: 2.4.9
connecting to: test
moogo:PRIMARY> 
```

Now, always in the primary server, you can create databases
and users with this:

```sh
mongo <create-dbs-users.js
```

**Warning:** you have to define at least a user with the roles
`userAdminAnyDatabase` and `clusterAdmin` to be able a replica
set UP.

Now, you have to authenticate in mongo before to create the
replica set. So manually add the replicatset members like this:

```sh
~# mongo
MongoDB shell version: 2.4.9
connecting to: test

> use admin # use the database where the user has been created.
switched to db admin

> db.auth('admin', 'xxxxxxxxxxxxx')
1

# Add members.
moogo:PRIMARY> rs.add("moogo02")
{ "ok" : 1 }
moogo:PRIMARY> rs.add("moogo03")
{ "ok" : 1 }
moogo:PRIMARY> 
```

And check that everything is fine:

```sh
moogo:PRIMARY> rs.status()
moogo:PRIMARY> show dbs
moogo:PRIMARY> 
moogo:PRIMARY> show users
```

And you can check on the non-primary mongos that you have this
(be careful, you have to authenticate in the non-primary
nodes too):

```sh
~# mongo
MongoDB shell version: 2.4.9
connecting to: test
> use admin
switched to db admin
> db.auth('admin', 'xxxxxxxxxxxxx')
1
moogo:SECONDARY> 
```

To have the status of the mongodb replica set, you can launch:

```sh
echo $'use admin\ndb.runCommand( { replSetGetStatus : 1 } )' | mongo
```


# TODO

* Write this readme file.

