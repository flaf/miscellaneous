# Module description

Basic module to just install and configure mongodb.

# Post puppet run

First time on the (expected to be) PRIMARY server (and ONLY
on ONE server):

```sh
echo 'rs.initiate()' | mongo
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

Manually add the replicatset members:

```
moogo:PRIMARY> rs.add("moogo02")
moogo:PRIMARY> rs.add("mongo03")
```

And check that everything is fine:

```sh
moogo:PRIMARY> rs.status()
moogo:PRIMARY> show dbs
moogo:PRIMARY> 
moogo:PRIMARY> show users
```

And you can check on the non-primary mongos you have this:

```sh
~# mongo
MongoDB shell version: 2.4.9
connecting to: test
moogo:SECONDARY> 
```

To have the status of the mongodb replica set, you can launch:

```sh
echo $'use admin\ndb.runCommand( { replSetGetStatus : 1 } )' | mongo
```


# TODO

* Write this readme file.

