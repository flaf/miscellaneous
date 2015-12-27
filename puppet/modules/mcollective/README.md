# Module description

This module configures mcollective server/client
and middleware with ssl.




# Mcollective architecture

First, here is a schema to summarize the mcollective architecture:

```
                 +----------------------------+
                 | The middleware service     |
                 |                            |
                 | Currently it's a           |
            +--->| RabbitMQ server.           |<------------+
            |    | It uses the STOMP          |             |
            |    | protocol port 61614.       |             |
            |    |                            |             |
            |    | RabbitMQ user: mcollective |             |
            |    | RabbitMQ pwd: 123456       |             |
            |    +----------------------------+             |
 2-way SSL  |                                               | 2-way SSL
 connection |    * Configuration at                         | connection
            |      /etc/rabbitmq/rabbitmq.config.           |
            |                                               |
            |    * It uses the certificate, the private     |
            |      key and the CA certificate from the      |
            |      puppet-agent service.                    |
            |                                               |
            |                                               |
            |                                               |
+-----------+--------------------+                    +-----+---------------------------------+
| A mcollective client           |                    | A mcollective server                  |
| (client Y)                     |                    |                                       |
|                                |                    |                                       |
| RabbitMQ user: mcollective     |                    | RabbitMQ user: mcollective            |
| RabbitMQ pwd: 123456           |                    | RabbitMQ pwd: 123456                  |
|                                |                    |                                       |
| Client private key: cprivY.pem |                    | Servers private key: spriv.pem        |
| Client public key:  cpubY.pem  |                    | Servers public key:  spub.pem         |
|                                |                    |                                       |
| Servers public key: spub.pem   |                    | Public keys of authorized clients:    |
|                                |                    |    - cpubY.pem                        |
|                                |                    |    - cpubZ.pem                        |
|                                |                    |    - ...                              |
+--------------------------------+                    +---------------------------------------+

* Configuration at                                    * Configuration at
  /etc/puppetlabs/mcollective/client.cfg.               /etc/puppetlabs/mcollective/server.cfg.

* It uses the certificate, the private key and the    * It uses the certificate, the private key and the
  CA certificate from the puppet-agent service to       CA certificate from the puppet-agent service to
  establish the SSL connection with the middleware.     establish the SSL connection with the middleware.

* Keys used by the client at                          * Keys used by the server at:
  /etc/puppetlabs/mcollective/client-keys/.               - /etc/puppetlabs/mcollective/server-keys/
                                                          - /etc/puppetlabs/mcollective/allowed-clients/
```

Keep in min this:

* The mcollective client sends commands.
* The mcollective servers receive commands from the client.
* The mcollective client and servers establish a connection
with the middleware (even the mcollective server requests
the middleware to establish a connection, this is not the
reverse).
* A host can be mcollective client *and* mcollective server
(and middleware too).

All the mcollective servers shared the same couple of public
and private keys. Each client has its own couple of private
and public keys.

To be able to send commands, a client must:
- have the password of the `mcollective` RabbitMQ user
(to connect to the middleware),
- establish a SSL connection with the middleware,
- have the shared public key of the servers (to send encrypted
messages to the servers),
- have its own couple of private and public keys.

To be able to receive and execute commands from a client,
a server must:
- have the password of the `mcollective` RabbitMQ user
(to connect to the middleware),
- establish a SSL connection with the middleware,
- have the public key of the client (to send encrypted messages to the client),
- have the shared private and public keys of the servers.

**Remark 1:** it's the same principle as SSH. A server
will accept commands from only clients of which it
has the public key in its configuration (like the
`ssh_authorized_keys` with SSH).

**Remark 2:** if a server is compromised by a hacker, the
hacker can receive commands from clients. You have to change
the shared private/public keys of the servers. If a client
is compromised by a hacker, it's a big problem. Indeed, the
hacker can launch commands on all servers. You have to
remove quickly the public key of the compromised client in all
servers (in the `/etc/puppetlabs/mcollective/allowed-clients/`
directory).




# The `mcollective::middleware` class

## Usage

Here is an example:

```puppet
class { '::mcollective::middleware':
  stomp_ssl_ip    => '0.0.0.0',
  stomp_ssl_port  => 61614,
  ssl_versions    => ['tlsv1.2', 'tlsv1.1'],
  puppet_ssl_dir  => '/etc/puppetlabs/puppet/ssl',
  admin_pwd       => 'xEd67+er',
  mcollective_pwd => '@mC0+45mpLSs',
  exchanges       => [ 'mcollective' ],
}
```

## Data binding

The `stomp_ssl_ip` parameter defines the address used by the
middleware server. The default value is the string
`'0.0.0.0'` which means "listening on any address of current
the host". The `stomp_ssl_port` parameter must be an integer
and its default value is `61614`. The `ssl_versions`
parameter is an array of non-empty strings which gives the
versions of TLS/SSL accepted by the middleware server. The
default value of this parameter is `['tlsv1.2', 'tlsv1.1']`.
The value `[]` (ie an empty array) is possible for this
parameter. In this case, no TLS/SSL version is explicitly
put in the RabbitMQ configuration so that the accepted
versions are the default accepted versions of the current
RabbitMQ server (and it depends on the version of the
installed software).

The `puppet_ssl_dir` parameter is the ssl directory of the
puppet installation. Indeed, this class installs a
middleware server with 2-way SSL connections and it uses the
certificate, the private key and the CA certificate of the
puppet agent (which is present in the `$ssldir` directory of
the puppet installation). The default value of this
parameter is the string `'/etc/puppetlabs/puppet/ssl'` which
is the ssl directory of a classical puppet 4 installation.
Normally, you should never need to change this setting.

The `admin_pwd` parameter is the password of the `admin`
rabbitMQ account. Its default value is `sha1($::fqdn)`.

The `mcollective_pwd` is the password of the `mcollective`
rabbitMQ account. For the default value of this parameter,
there is a lookup in hiera or in the `environment.conf`.
**You must provide this entry**:

```yaml
mcollective:
  middleware_mcollective_pwd: '<value-of-mcollective-pwd>'
  middleware_exchanges: [ 'mcollective', 'dc2' ] # optional (see below).
```

As you can see in the schema above, the mcollective password
is shared by the middleware, the clients and the servers. So
you will probably put this entry in a `common.yaml` file in
hiera or something like that.

The `exchanges` parameter is an array of strings which
contains the created exchanges. This parameter can be empty
and its default value is `[ 'mcollective' ]` or, if present,
the value of the sub-entry `middleware_exchanges` of the
hiera entry `mcollective`. The class handles this parameter
and appends the `'mcollective'` string if not present.


# The `mcollective::server` class

## Usage

Here is an example:

```puppet
$pubkey  = '<content-of-the-public-key>'
$privkey = '<content-of-the-private-key>'

class { '::mcollective::server':
  collectives        => [ 'mysql', 'foo' ],
  server_private_key => $privkey,
  server_public_key  => $pubkey,
  server_enabled     => true,
  connector          => 'rabbitmq',
  middleware_address => '172.31.10.12',
  middleware_port    => 61614,
  mcollective_pwd    => '@mC0+45mpLSs',
  mco_tag            => 'mcollective_clients_pub_keys',
  puppet_ssl_dir     => '/etc/puppetlabs/puppet/ssl',
}
```

## Data binding

Some of these parameters will be searched via a lookup in
hiera or in the `environment.conf` and **you must provide
these entries**:

```yaml
mcollective:
  middleware_mcollective_pwd: '<value of the $mcollective_pwd parameter>'
  middleware_address: '<value of the $middleware_address parameter>'
  server_private_key: '<value of the $server_private_key parameter>'
  server_public_key: '<value of the $server_public_key parameter>'
  server_enabled: '<value of the $server_enabled parameter>' # optional entry (see below)
  tag: '<value of the $mco_tag parameter>' # optional entry (see below)
  collectives: [ 'mcollective', 'mysql' ]  # optional entry (see below)
```

The `server_private_key` and `server_public_key` parameters
are non-empty strings to provide mcollective private and
public keys shared by all the servers. To generate these
keys, you can execute these commands:

```sh
# Generate the private key.
openssl genrsa -out 'private_key.pem' 4096

# Generate the public key matching the previous private key.
openssl rsa -in 'private_key.pem' -out 'public_key.pem' -outform PEM -pubout
```

The `collectives` parameter sets the `collectives` parameter
in the `server.cfg` file (see
[here](https://docs.puppetlabs.com/mcollective/configure/server.html#collectives)
for more details). The type of this parameter is an array of
strings (the array can be empty). The default value of this
parameter is `[ 'mcollective' ]` or, if present, the value
of the `collectives` sub-entry of the hiera entry
`mcollective`. This parameter is handled in the class:
- if not already present, the string `'mcollective'` is automatically
appended in the `collectives` parameter,
- if not already present and if not undefined the value of
`$::datacenter` is automatically appended in the `collectives` parameter.

**warning :** be careful, the collectives used by the mcollective
server must exist as exchanges in the middleware server.

The `connector` parameter is the connector used by mcollective
to connect to the middleware server. The authorized values are
only `rabbitmq` or `activemq`. Its default value is `rabbitmq`.

The `middleware_address` parameter is the address of the
middleware server (an IP, a fqdn etc). The default value
of this parameter is set in the hiera entries above.

The `middleware_port` parameter is the port used by the
middleware server. It's an integer and its default value
is `61614`.

The `mcollective_pwd` parameter is the password of the
`mcollective` rabbitMQ account. The default value of this
parameter is set in the hiera entries above.

The `mco_tag` parameter is a non-empty string which gives the
name of the tag used to import public keys of the
mcollective clients. Indeed, the mcollective servers need the
public keys of each authorized client in its configuration.
Each client will export its public key with a specific tag
and the servers will retrieve these public keys via the same
tag given by the `mco_tag` parameter. The default value of
this parameter can be set by the `tag` entry in the hiera
entries above but it's optional. If the `tag` entry is not
present, the value `'mcollective_client_public_key'` will be
used.

The `server_enabled` parameter is a boolean and its default
value is `true`. If it is set to `false` the mcollective
service will be stopped and disabled (no automatic start
during the boot). This parameter is completely optional.

The `puppet_ssl_dir` parameter has exactly the same meaning
of the `puppet_ssl_dir` parameter in the
`::mcollective::middleware` class.




# The `mcollective::client` class

## Usage

Here is an example:

```puppet
$client_pubkey  = '<content-of-the-public-key>'
$client_privkey = '<content-of-the-private-key>'
$server_pubkey  = '<content-of-the-public-servers-public-key>'

class { '::mcollective::client':
  collectives        => [ 'mysql', 'foo' ],
  client_private_key => $server_pubkey,
  client_public_key  => $client_pubkey,
  server_public_key  => $server_pubkey,
  mco_tag            => 'mcollective_clients_pub_keys',
  connector          => 'rabbitmq',
  middleware_address => '172.31.10.12',
  middleware_port    => 61614,
  mcollective_pwd    => '@mC0+45mpLSs',
  puppet_ssl_dir     => '/etc/puppetlabs/puppet/ssl',
}
```

## Data binding

The `collectives` parameter sets the `collectives` parameter
in the `client.cfg` file. The type of this parameter is an
array of strings (the array can be empty). The default value
of this parameter is `[ 'mcollective' ]` or, if present, the
value of the `middleware_exchanges` sub-entry of the hiera
entry `mcollective`. This parameter is handled in the class:
- if not already present, the string `'mcollective'` is automatically
appended in the `collectives` parameter,
- if not already present and if not undefined the value of
`$::datacenter` is automatically appended in the `collectives` parameter.

Except the `client_private_key` and `client_public_key`
parameters, the remaining parameters have exactly the same
meaning of the parameters of the `::mcollective::server`
class. The meaning of the `client_private_key` and
`client_public_key` parameters is clear. The default values
of these parameters will be set via a lookup in hiera or in
the `environment.conf` (see below). Finally for a
mcollective client **you must provide these entries**:

```yaml
mcollective:
  client_private_key: '<value of the $client_private_key parameter>'
  client_public_key: '<value of the $client_public_key parameter>'
  middleware_mcollective_pwd: '<value of the $mcollective_pwd parameter>'
  middleware_address: '<value of the $middleware_address parameter>'
  server_public_key: '<value of the $server_public_key parameter>'
  #tag: '<value of the $mco_tag parameter>' # optional entry
```




# TODO

* The `mcollective::middleware` class installs a RabbitMQ
server. But RabbitMQ seems to not support certificate revocation
list (crl). Is it the case with Activemq? Activemq is in Ubuntu
repositories now.

* The mcollective `shell` plugin and the mcollective `puppet` plugin
are not currently packaged in the PC1 APT repository. But it's expected
to add these packages in PC1
(see [here](https://groups.google.com/forum/#!topic/puppet-users/XSSXGY_rmy0)).

* Need to split this module in 3 different modules: `mcollective_middileware`,
`mcollective_server` and `mcollective_client`. It will be better as
regard the data handle.


