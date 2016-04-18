# Module description

This module configures mcollective server/client.

Remark: this module implements the "params" design pattern.



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




# The `mcollective::server` class

## Usage

Here is an example:

```puppet
$pubkey  = '<content-of-the-public-key>'
$privkey = '<content-of-the-private-key>'

class { '::mcollective::server::params':
  collectives        => [ 'mysql', 'foo', 'bar' ],
  private_key        => $privkey,
  public_key         => $pubkey,
  service_enabled    => true,
  connector          => 'rabbitmq',
  middleware_address => '172.31.10.12',
  middleware_port    => 61614,
  mcollective_pwd    => '@mC0+45mpLSs',
  mco_tag            => 'mcollective_clients_pub_keys',
  mco_plugin_agents  => [ 'mcollective-flaf-agents' ],
  puppet_ssl_dir     => '/etc/puppetlabs/puppet/ssl',
  puppet_bin_dir     => '/opt/puppetlabs/puppet/bin',
}

include '::mcollective::server'
```




## Parameters

The `collectives` parameter is an array of strings.
The mcollective server will belong to the collectives put in
this parameter. The default value of this parameter is `[
'collective' ]` or `[ 'collective', $::datacenter ]` if
`$::datacenter` is defined. The default merging policy of
this `server_collectives` parameter is `unique`.




The `private_key` and `public_key` parameters
are non-empty strings to provide mcollective private and
public keys shared by all the servers. These parameters have
the default value `undef` which not accepted by the
`mcollective::server` class (in clear you must define these
parameter in hiera).

To generate these keys, you can execute these commands:

```sh
# Generate the private key.
openssl genrsa -out 'private_key.pem' 4096

# Generate the public key matching the previous private key.
openssl rsa -in 'private_key.pem' -out 'public_key.pem' -outform PEM -pubout
```

The `service_enabled` parameter is a boolean and its default
value is `true`. If set to `false`, the mcollective service
will be stopped and disabled (no automatic start during the
boot).

The `connector` parameter is the connector used by
mcollective to connect to the middleware server. The
authorized values are only `rabbitmq` or `activemq`. Its
default value is `rabbitmq`.

The `middleware_address` parameter is the address of the
middleware server (an IP, a fqdn etc). The default value
of this parameter is `undef`. In clear, you must define the
value of this parameter.

The `middleware_port` parameter is the port used by the
middleware server. It's an integer and its default value is
`undef` (you have to define the value of this parameter).

The `mcollective_pwd` parameter is the password of the
`mcollective` rabbitMQ account. The default value of this
parameter is `undef` (you have to define the value of this
parameter).

The `mco_tag` parameter is a non-empty string which gives
the name of the tag used to import public keys from the
mcollective clients. Indeed, the mcollective servers need
the public keys of each authorized client in its
configuration. Each client will export its public key with a
specific tag (tag defined by the present `mco_tag` parameter
itself) and the servers will retrieve these public keys via
the same tag given by the `mco_tag` parameter. The default
value of this parameter is `'mcollective_client_public_key'`.

The `mco_plugin_agents` is an array of supplementary
mcollective agent packages which will be installed. The
default value is `[]`.

The `puppet_ssl_dir` parameter is the ssl directory of the
`puppet-agent` package (mcollective servers and clients use
the certificate present in this directory). The default
value of this parameter is `undef` (you have to define the
value of this parameter).

The `puppet_bin_dir` parameter is the bin directory of the
`puppet-agent` package. The default value of this parameter
is `undef` (you have to define the value of this parameter).




# The `mcollective::client` class

## Usage

Here is an example:

```puppet
$client_pubkey  = '<content-of-the-public-key>'
$client_privkey = '<content-of-the-private-key>'
$server_pubkey  = '<content-of-the-public-servers-public-key>'

class { '::mcollective::client::params':
  collectives        => [ 'mysql', 'foo' ],
  private_key        => $server_pubkey,
  public_key         => $client_pubkey,
  server_public_key  => $server_pubkey,
  connector          => 'rabbitmq',
  middleware_address => '172.31.10.12',
  middleware_port    => 61614,
  mcollective_pwd    => '@mC0+45mpLSs',
  mco_tag            => 'mcollective_clients_pub_keys',
  mco_plugin_clients => [ 'mcollective-flaf-clients' ],
  puppet_ssl_dir     => '/etc/puppetlabs/puppet/ssl',
}

include '::mcollective::client'
```




## Parameters

The `private_key` and `public_key` are the keys of the
mcollective client. The default value is `undef` which is
not accepted by the class `mcollective::client` (you must
define explicitly the values).

The `mco_plugin_clients` is an array of supplementary
mcollective client packages which will be installed. The
default value is `[]`.

The other parameters have been already described in the
previous section.




# TODO

* The `mcollective::middleware` class installs a RabbitMQ
server. But RabbitMQ seems to not support certificate revocation
list (crl). Is it the case with Activemq? Activemq is in Ubuntu
repositories now.


