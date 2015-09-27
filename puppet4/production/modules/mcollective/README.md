# Module description

This module configures mcollective server/client
and middleware with ssl.



# The `mcollective::middleware` class

## Usage

Here is an example:

```puppet
class { '::mcollective::middleware':
  stomp_ssl_ip    => '0.0.0.0',
  stomp_ssl_port  => 61614,
  puppet_ssl_dir  => '/etc/puppetlabs/puppet/ssl',
  admin_pwd       => 'xEd67+er',
  mcollective_pwd => '@mC0+45mpLSs',
}
```

## Data binding

The `stomp_ssl_ip` parameter defines the address used by
the middleware server. The default value is the string
`'0.0.0.0'` which means "any address of the host".
The `stomp_ssl_port` parameter must be an integer
and its default value is `61614`.

The `puppet_ssl_dir` parameter is the ssl directory
of the puppet installation. Indeed, this class installs
a middleware server with ssl and it uses the certificate
of the puppet client (which is present in the ssl
directory of the puppet installation). The default value
of this parameter is the string `'/etc/puppetlabs/puppet/ssl'`
which is the ssl directory of a classical puppet 4
installation.

The `admin_pwd` parameter is the password of the `admin`
rabbitmq account and `mcollective_pwd` is the password
of the `mcollective` rabbitmq account.

For the default values of these parameters, there is
a lookup in hiera or in the `environment.conf`. **You
must provide this entry**:

```yaml
mcollective:
  middleware_admin_pwd: '<value-of-admin_pwd>'
  mcollective_pwd: '<value-of-mcollective_pwd>'
```


# mcollective architecture

Here is a schema to resume the mcollective architecture:

```
                 +-------------------------+
                 | The middleware service  |
                 |                         |
                 |   Currently it's a      |
            +--->|   RabbitMQ server.      |<---------------+
            |    |   It uses the STOMP     |                |
            |    |   protocol port 61614.  |                |
            |    +-------------------------+                |
2-way SSL   |                                               | 2-way SSL
connection  |    * Configuration at                         | connection
            |      /etc/rabbitmq/rabbitmq.config.           |
            |                                               |
            |    * It uses the certificate, the private     |
            |      key and the CA certificate from the      |
            |      puppet-agent service.                    |
            |                                               |
            |                                               |
            |                                               |
+-----------+--------------------+                    +-----+---------------------------------+
| The mcollective client         |                    | A mcollective server                  |
| (client Y)                     |                    |                                       |
|                                |                    |                                       |
| shared password: 123456        |                    | shared password: 123456               |
|                                |                    |                                       |
| Client private key: cprivY.pem |                    | Servers private key: spriv.pem        |
| Client public key:  cpubY.pem  |                    | Servers public key:  spub.pem         |
| Servers public key: spub.pem   |                    |                                       |
|                                |                    | Public keys of authorized clients:    |
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
nd public keys.

To be able to send commands, a client must:
- establish a SSL connection with the middleware,
- have the shared password,
- have the shared public key of the servers (to send encrypted
messages to the servers),
- have its own couple of private and public keys.

To be able to receive and execute commands from a client,
a server must:
- establish a SSL connection with the middleware,
- have the shared password,
- have the public key of each client,
- have the shared private and public keys of servers.

**Remark 1:** it's the same principle as SSH. A server
will accept commands from only clients of which the server
has the public key in its configuration (like the
`ssh_authorized_keys` with SSH).

**Remark 2:** if a server is compromised by a hacker, the
hacker can receive commands from clients. You have to change
the shared private/public keys of the servers. If a client
is compromised by a hacker, it's big problem. Indeed, the
hacker can launch commands on all servers. You have to
remove quickly the public of the client in all the servers
(in `/etc/puppetlabs/mcollective/allowed-clients/`).





# TODO

* The `mcollective::middleware` class installs a RabbitMQ
server. But RabbitMQ seems to not support certificate revocation
list (crl). Is it the case with Activemq? Activemq is in Ubuntu
repositories now.

* The README is absolutely not finished. Don't forget
to draw a schema like in
[this page](https://docs.puppetlabs.com/mcollective/overview_components.html).

* Implement the installation of the `shell` plugin and
the `puppet` plugin. Take the packages from puppet 3.x
and just change the paths.



