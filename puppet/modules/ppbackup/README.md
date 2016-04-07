# Module description

This module is a simple commodity to manage a basic user
`ppbackup` to store backups in its home. This user has no
specific privilege and can accept "ssh authorized keys" to
allow non-interactive ssh or scp from other hosts.

This module provide two defined resources
`ppbackup::mcrypt_user` and `ppbackup::ssh_authorized_key`.




# Usage

Here is an example:

```puppet
::ppbackup::mcrypt_user { 'root':
  password => $mcrypt_pwd,
}

::ppbackup::ssh_authorized_key { "root@backup-srv":
  type   => 'ssh-rsa',
  key    => 'AAAAB3N....aH/',
}
```

With this code:

- The root user will be able to crypt files with the `mcrypt`
command which will be non-interactive because the first defined
resource manage the file `/root/.mcryptrc` which contains the
mcrypt password. So, for instance, via cron tasks the root
user will be able to make a backup B, encrypt it and put it in
`/home/ppbackups`.

- The ppbackup user and his home will be created and a specific
ssh public key will be added in his `~/.authorized_keys` file.
Thus, a user who owns the private key will able to retrieve the
backup B with a simple and non-interactive scp.




# Parameters of `ppbackup::ssh_authorized_key`

When a such resource is applied the user ppbackup is
automatically created. This user has no specific privilege
and his Unix password is locked.

The `keyname` of the key is the comment of the public key.
It's a string and its default value is the title of the
resource.

The `type` parameter is the type of the ssh public key.
For instance, `ssh-rsa` which is the default value of this
parameter.

The `key` parameter is the content of the ssh public key.




# Parameters of `ppbackup::mcrypt_user`

This resource just manages the file `~/.mcryptrc` of the
user and set the mycrypt password and the algorithm.

The `user` parameter gives the owner of the `.mcryptrc`
file. Its default value is the title of the resource. The
user must exist.

The `home` parameter is the path of the user's home. The
default value is `/root` is the user is root, else it's
`/home/${user}/.mcryptrc`.

The `password` parameter is the mcrypt password. There
is no default value.

The `algorithm` parameter is the algorithm used by the
mcrypt command. Its default value is `'rijndael-256'`.




