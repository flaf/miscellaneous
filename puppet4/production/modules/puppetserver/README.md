# Module description

This module allows to install a Puppet4 server.




# A security point

The propagation of the CRL (Certificate Revocation List)
of the CA is an important point:

* puppetserver uses a CRL and must be restarted when the CRL
is updated. Typically, after a simple `puppet node clean $fqdn`,
the client is able to run puppet until the puppertserver has
been restarted.

* Same remark for puppetdb.




# TODO

* Make a schema with puppetserver, puppetdb and postresql.

* A client uses the `$ssldir/crl.pem` file as CRL. This file
should be the same as the file `$ssldir/ca/ca_crl.pem` in
the puppet CA. We could imagine the CA which exports this
file `$ssldir/ca/ca_crl.pem` and puppet-agents retrieve this
file... Currently, if a "client" puppetserver P is revoked
by its "autonomous" puppetserver, the clients of puppet P
will always be able to do a puppet run (with a request to
puppet P) without any error.


