# Module description

This module installs a MCollective middleware (via RabbitMQ).
It's a 2-way SSL RabbitMQ server.


# Usage

Here is an example:

```puppet
class { '::mcomiddleware::params'
  stomp_ssl_ip    => '0.0.0.0',
  stomp_ssl_port  => 61614,
  ssl_versions    => [ 'tlsv1.2', 'tlsv1.1' ],
  puppet_ssl_dir  => '/etc/puppetlabs/puppet/ssl',
  admin_pwd       => '123456',
  mcollective_pwd => 'xyz123',
  exchanges       => [ 'mcollective' ],
}

include '::mcomiddleware'
```


# Parameters

The `stomp_ssl_ip` parameter defines the address used by the
middleware server. The default value is the string
`'0.0.0.0'` which means "listening on any address of current
the host".

The `stomp_ssl_port` parameter must be an integer and its
default value is `61614`.

The `ssl_versions` parameter is an array of non-empty
strings which gives the versions of TLS/SSL accepted by the
middleware server. The default value of this parameter is
`['tlsv1.2', 'tlsv1.1']`. The value `[]` (ie an empty array)
is possible for this parameter. In this case, no TLS/SSL
version is explicitly put in the RabbitMQ configuration so
that the accepted versions are the default accepted versions
of the current RabbitMQ server (and it depends on the
version of the installed software).

The `puppet_ssl_dir` parameter is the ssl directory of the
puppet installation. Indeed, this class installs a
middleware server with 2-way SSL connections and it uses the
certificate, the private key and the CA certificate of the
puppet agent (which is present in the `$ssldir` directory of
the puppet installation). The default value of this
parameter is `undef`, so you must provided a value explicitly.

The `admin_pwd` parameter is the password of the `admin`
rabbitMQ account. Its default value is `undef` which will be
not accepted by the class `mcomiddleware`. In clear, you
must provide explicitly (for instance with hiera) a value
for this parameter.

The `mcollective_pwd` is the password of the `mcollective`
rabbitMQ account. For its default value it's the same as
the `admin_pwd` parameter above.

The `exchanges` parameter, an array of strings, is the
exchanges created automatically in the RabbitMQ server. If a
MCollective server uses a collective `foo`, you must create
the `foo` exchange in the RabbitMQ server. The default value
of this parameter is `[ 'mcollective' ]`. In any case, the
`'mcollective'` exchanges is automatically added if not
present in the `exchanges` parameter.


# TODO

* The class `mcomiddleware` is awful (lot of exec resources etc).
  Could it be simpler with Activemq etc.?


