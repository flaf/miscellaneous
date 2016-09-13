# Module description

This module just installs and configures an null client
(mail) via Exim4.


# Usage

Here is an example:

```puppet
$dc_smarthost = [
  { 'address' => 'smtp1.dom.tld', 'port' => 25 },
  { 'address' => 'smtp2.dom.tld', 'port' => 25 },
]

class { '::eximnullclient::params':
  dc_smarthost         => $dc_smarthost,
  redirect_local_mails => 'admin@dom.tld',
  prune_from           => true,
}

include '::eximnullclient'
```

# Parameters

The `dc_smarthost` parameter in a non-empty list of
smarthosts used by Exim to send mails. This parameter must
have the same structure as in the example above.

The `redirect_local_mails` parameter allow to redirect to a
specific address any mail to a local Unix account (and
especially the mails from cron tasks). The default value of
this parameter value is `''` (an empty string) and in this
case there is no redirection. If the value is a non-empty
string, the redirection is set with the value of this
parameter.

The `prune_from` parameter is a boolean. If set to `true`,
which is the default, before to send mail, the `From` field
will be rewritten by Exim to just contain the mail. For
instance, this `From` field :

```
root@foo.dom.tld (Cron Daemon)
```

will be just changed to `root@foo.dom.tld`. If set to
`false`, the `From` field will be unchanged.


