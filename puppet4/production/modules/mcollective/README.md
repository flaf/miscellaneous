# Module description

This module configures mcollective server/client
and middleware (with ssl).



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



