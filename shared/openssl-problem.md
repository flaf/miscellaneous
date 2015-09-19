# My openssl problem

I have 2 hosts:

* A client called `puppet4` on Ubuntu Trusty 14.04 (updated).
* A server called `middleware` which is a RabbitMQ server
on Ubuntu Trusty 14.04 (updated too). I have set the server
to use only ssl/tls connections.

On the client, I have 2 different versions of openssl:

* the "old" version which is the `1.0.1f` version provided
by the official Ubuntu repositories.

* the "new" version which is the `1.0.2d` version provided
by a installation of a package (`puppet-agent`) from an
additional and non-official repository (https://apt.puppetlabs.com/).

**My problem**: my problem is that the "old" version of
openssl succeeds to make a ssl connection but the "new"
doesn't succeeds. I would like the "new" version of openssl
succeeds too (and I would like to understand why it
currently doesn't work).

In the client `puppet4`, I set some variables:

```sh
# The address of the middleware server.
MIDDLEWARE_SRV="172.31.14.7:61614"

# I set the paths of the certificate of my client, its
# private key and the certificate of the CA.
cert="/etc/puppetlabs/puppet/ssl/certs/$(hostname -f).pem"
key="/etc/puppetlabs/puppet/ssl/private_keys/$(hostname -f).pem"
cacert="/etc/puppetlabs/puppet/ssl/certs/ca.pem"
```

Now, I try a ssl connection with the "old" version of openssl:

```sh
root@puppet4:~# /usr/bin/openssl version
OpenSSL 1.0.1f 6 Jan 2014


# Now I try a ssl handshake with the server. It succeeds.
root@puppet4:~# /usr/bin/openssl s_client -connect "$MIDDLEWARE_SRV" -cert "$cert" -key "$key" -CAfile "$cacert" && echo 'ALL IS OK'
CONNECTED(00000003)
depth=1 CN = Puppet CA: puppet4.athome.priv
verify return:1
depth=0 CN = middleware.athome.priv
verify return:1
---
Certificate chain
 0 s:/CN=middleware.athome.priv
   i:/CN=Puppet CA: puppet4.athome.priv
 1 s:/CN=Puppet CA: puppet4.athome.priv
   i:/CN=Puppet CA: puppet4.athome.priv
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFgjCCA2qgAwIBAgIBAzANBgkqhkiG9w0BAQsFADApMScwJQYDVQQDDB5QdXBw
ZXQgQ0E6IHB1cHBldDQuYXRob21lLnByaXYwHhcNMTUwOTE1MTkyODAwWhcNMjAw
OTE0MTkyODAwWjAhMR8wHQYDVQQDDBZtaWRkbGV3YXJlLmF0aG9tZS5wcml2MIIC
IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA7rrom3DIxEacFT2SIpnlrMDL
UYaE1m0B2IRJb0XFWLAhCjUZO+ImebxVRbxr8Un7hW9oNlgMD6jlYkXsNqFLD2ib
afatD6m5yxUOmoN3xb/b6d78nnL+Ia1BqZPJCGIEN1Pwh+lQMaaHPXl2SDId/qXc
c/a+uqpTStsjTwFT4sAur6GipqEJUhNUJ2D46fsC00IjS3r3XnHONkNUkD+K9h9y
rsWZzBZknv4niD73Pl3yPTD6OG03eQeXnf9je+Gce860PU/ocPPljdLUCj0opTW3
UcgVTkjgmsa7JAtbhQX2QNK62POZfcOnwE1RnAJp1bOuXFbK+MMnf9weC3ou+Mn2
K95yJcZUqXgeqB5I4nBk1zaYYsaIX+qK3c93YgvboquN3xxe3j3nZdkNjYVBxV6n
ZhpT7xeyNkxg8bZDaVYDeBC6wuCrOX6XCgAFO+mnd1rZsC6mU/bEby4x1NJmrBlJ
vVR+xY8qvRnaCTfhJd5bDx7o1r3XN8o9yaA+384qbR2tkdHQAP0S6Af+IP7pjKX4
aN3w8wlyhW1A61xrSNtalltoHRW87+Ls8cwHBDUEngJnNQ+WDbjVaFZmmBHxLwHe
UuqTRVNYVKD+4PWloomwKoJ8mfgrebP5/z32abpihoWeZPnjQOgva8FWoaw/kovV
7aMjKK6TmLX27WEwU1kCAwEAAaOBvDCBuTA3BglghkgBhvhCAQ0EKgwoUHVwcGV0
IFJ1YnkvT3BlblNTTCBJbnRlcm5hbCBDZXJ0aWZpY2F0ZTAOBgNVHQ8BAf8EBAMC
BaAwIAYDVR0lAQH/BBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQC
MAAwHQYDVR0OBBYEFKG/7yqvYPw5pyo0MKxRJGakVC/KMB8GA1UdIwQYMBaAFPhB
3xS4C7HbjQcuV26CT0SoKI5vMA0GCSqGSIb3DQEBCwUAA4ICAQCRDHrCvZRZ5efT
Vj5MdTxv6JRvTJOFslrBCKbgrscThZE55aHSyWtAwpARPFrsQGy9rwjCq33eDe+Y
uk8GtoAhOhnmLzxJx+mPjAjSQNbpXXDH5KgwAtDSQvZQGw+cuqZssI8dfOZVb73J
85n1r75ghDR9vrR90q2HFsIa9lIJeVatAUKrTS4v+0t5NQ4KoSC0lFSlhI+MzD9j
G67ZVoh8yaxFBAo/UZEDB0VquinExv6CAfo/OZrJRinWc9O89tJsRrREgXPNA0DX
PZxeZXKALlwgC0rxUshEIYgy8V3GWk5lUYAWQyhOH6EV5HpdXpB+AuMHi9MdrBl/
bFQvji0lmd4bOncO3rCm5JXXHWJJiHC6oWpp+3UVcgL1LPhgkNnmbKSNZlA2RA3Y
zU/Cn0xdNtQU0xQLHRTSuZKGjRztyy9waORVnNiUyBT1rahEg+T1OuR/CDRYg6pb
NrArSjdejw5CjFXqq3vCnTv4AvhP2LUU0Bb8e8mkr7KZAexhGAzL7lXNRRsIbr+2
5QPg5LzN4o6ivAmUzkp6wOjNujyelApu5yGd+78smveZvjjShQEU2EtwEjZuFVbk
JSw8Rl2grGKCoEyAHd0NEXlUQwSLN7UID8DtkdvaOUsuxlAzjN4HKWLeCF9hLnNu
sVeVB08LqTRrlg+2lEWbU+yVP0D2Og==
-----END CERTIFICATE-----
subject=/CN=middleware.athome.priv
issuer=/CN=Puppet CA: puppet4.athome.priv
---
Acceptable client certificate CA names
/CN=Puppet CA: puppet4.athome.priv
---
SSL handshake has read 3732 bytes and written 3884 bytes
---
New, TLSv1/SSLv3, Cipher is ECDHE-RSA-AES256-SHA384
Server public key is 4096 bit
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES256-SHA384
    Session-ID: F222F50CAD3419D82B93FE549E9452A8E7AAFCD5608BD0866EAF25FC8FEF3A6C
    Session-ID-ctx: 
    Master-Key: 31FEBCD2DDBA511BCB73B7747A5E6FC2E0EEB8BB3F1DF97D1AC744481163FB7F73373014CB6814CB34BD7ED71681D1E1
    Key-Arg   : None
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1442663377
    Timeout   : 300 (sec)
    Verify return code: 0 (ok)
---
QUIT
DONE
ALL IS OK
root@puppet4:~#
```

Now, I try the same but with the "new" version of openssl.
It fails as you can see:

```sh
# The version of openssl is more recent here.
root@puppet4:~# /opt/puppetlabs/puppet/bin/openssl version
OpenSSL 1.0.2d 9 Jul 2015

# And now the ssl handshake which fails.
root@puppet4:~# /opt/puppetlabs/puppet/bin/openssl s_client -connect "$MIDDLEWARE_SRV" -cert "$cert" -key "$key" -CAfile "$cacert" || echo 'THERE IS A PROBLEM'
CONNECTED(00000003)
140057737873056:error:140790E5:SSL routines:ssl23_write:ssl handshake failure:s23_lib.c:177:
---
no peer certificate available
---
No client certificate CA names sent
---
SSL handshake has read 0 bytes and written 285 bytes
---
New, (NONE), Cipher is (NONE)
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
---
THERE IS A PROBLEM
root@puppet4:~# 
```

If it could be helpful for you (this is not for me), here is the
output of the same command but with the `-debug` option:

```
CONNECTED(00000003)
write to 0xc37310 [0xc37390] (285 bytes => 285 (0x11D))
0000 - 16 03 01 01 18 01 00 01-14 03 03 3a d1 29 44 cc   ...........:.)D.
0010 - b5 a8 ed f7 68 0e e1 40-ba 3b 70 a5 6e d8 74 68   ....h..@.;p.n.th
0020 - 79 bc ce 63 5c fd 53 f0-13 91 a0 00 00 a2 c0 30   y..c\.S........0
0030 - c0 2c c0 28 c0 24 c0 14-c0 0a 00 a5 00 a3 00 a1   .,.(.$..........
0040 - 00 9f 00 6b 00 6a 00 69-00 68 00 39 00 38 00 37   ...k.j.i.h.9.8.7
0050 - 00 36 c0 32 c0 2e c0 2a-c0 26 c0 0f c0 05 00 9d   .6.2...*.&......
0060 - 00 3d 00 35 c0 2f c0 2b-c0 27 c0 23 c0 13 c0 09   .=.5./.+.'.#....
0070 - 00 a4 00 a2 00 a0 00 9e-00 67 00 40 00 3f 00 3e   .........g.@.?.>
0080 - 00 33 00 32 00 31 00 30-00 9a 00 99 00 98 00 97   .3.2.1.0........
0090 - c0 31 c0 2d c0 29 c0 25-c0 0e c0 04 00 9c 00 3c   .1.-.).%.......<
00a0 - 00 2f 00 96 00 07 c0 11-c0 07 c0 0c c0 02 00 05   ./..............
00b0 - 00 04 c0 12 c0 08 00 16-00 13 00 10 00 0d c0 0d   ................
00c0 - c0 03 00 0a 00 15 00 12-00 0f 00 0c 00 09 00 ff   ................
00d0 - 01 00 00 49 00 0b 00 04-03 00 01 02 00 0a 00 10   ...I............
00e0 - 00 0e 00 17 00 19 00 1c-00 1b 00 18 00 1a 00 16   ................
00f0 - 00 23 00 00 00 0d 00 20-00 1e 06 01 06 02 06 03   .#..... ........
0100 - 05 01 05 02 05 03 04 01-04 02 04 03 03 01 03 02   ................
0110 - 03 03 02 01 02 02 02 03-00 0f 00 01 01            .............
read from 0xc37310 [0xc3c8f0] (7 bytes => 0 (0x0))
139667561330336:error:140790E5:SSL routines:ssl23_write:ssl handshake failure:s23_lib.c:177:
---
no peer certificate available
---
No client certificate CA names sent
---
SSL handshake has read 0 bytes and written 285 bytes
---
New, (NONE), Cipher is (NONE)
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
---
THERE IS A PROBLEM
root@puppet4:~#
```

Maybe helpful too, here the configuration of my RabbitMQ
server, ie the `/etc/rabbitmq/rabbitmq.config` file. This
is a RabbitMQ server version 3.2.4 provided by the Ubuntu
distribution. I have tried too the 3.5.4 version provided
by the RabbitMQ team but I have exactly the same problem:

```erlang
[

  {
    rabbitmq_stomp,
      [
        {
          % No STOMP tcp connection allowed.
          tcp_listeners, []
        },
        {
          % STOMP ssl connections allowed.
          ssl_listeners,
            [
              {"0.0.0.0", 61614}
            ]
        }
      ]
  },

  { ssl, [{ versions, [ 'tlsv1.2', 'tlsv1.1', 'tlsv1' ] }] },

  {
    rabbit,
      [
        {
          % No AMQP tcp connection allowed.
          tcp_listeners, []
        },
        {
          % No AMQP ssl connection allowed.
          ssl_listeners, []
        },
        {
          % - fail_if_no_peer_cert == true means "don't accept connection of
          %   client which has not a certificate".
          % - verify == verify_peer means "don't accept connection of client
          %   if its certificate doesn't valid the chain of trust with the CA".
          ssl_options,
            [
              {          cacertfile, "/etc/rabbitmq/ssl/cacert.pem"},
              {            certfile, "/etc/rabbitmq/ssl/cert.pem"},
              {             keyfile, "/etc/rabbitmq/ssl/key.pem"},
              {              verify, verify_peer},
              {            versions, [ 'tlsv1.2', 'tlsv1.1', 'tlsv1' ]},
              {fail_if_no_peer_cert, true}
            ]
        }
      ]
  },

  {
    rabbitmq_management,
      [
        {
          % The WebUI for management.
          listener,
            [
              {  ip, "127.0.0.1"},
              {port, 15672}
            ]
        },
        {
          % Without this parameter, the RabbitMQ WebUI continue
          % to listen on 55672 (old port for RabbitMQ < 3.0).
          redirect_old_port, false
        }
      ]
  }

].
```

During the ssl handshake which fails, here is the logs
in RabbitMQ server side:

* First with the log in the file `/var/log/rabbitmq/rabbit@middleware-sasl.log`
(not helpful for me). It's [here](http://pastebin.ca/3166183).

* Second, with the file `/var/log/rabbitmq/rabbit@middleware.log`
(for me this is completely incomprehensible).
It's [here](http://pastebin.ca/3166180).


Last information, if I change the configuration of the
RabbitMQ server to allow sslv3 too, the "new" openssl
version succeeds to the handshake. I just change this
2 lines in the file `/etc/rabbitmq/rabbitmq.config` (I
just add `sslv3` in the arrays):

```
  { ssl, [{ versions, [ 'sslv3', 'tlsv1.2', 'tlsv1.1', 'tlsv1' ] }] },

  ...

              {            versions, [ 'sslv3', 'tlsv1.2', 'tlsv1.1', 'tlsv1' ]},

  ...
```

After that (and a restart of the RabbitMQ server of course),
I can make a ssl handshake with the "new" openssl version but
I must add the `-ssl3` option:

```sh
root@puppet4:~# /opt/puppetlabs/puppet/bin/openssl s_client -connect $MIDDLEWARE_SRV -cert $cert -key $key -CAfile $cacert -ssl3 || echo 'ALL IS OK'
CONNECTED(00000003)
depth=1 CN = Puppet CA: puppet4.athome.priv
verify return:1
depth=0 CN = middleware.athome.priv
verify return:1
---
Certificate chain
 0 s:/CN=middleware.athome.priv
   i:/CN=Puppet CA: puppet4.athome.priv
 1 s:/CN=Puppet CA: puppet4.athome.priv
   i:/CN=Puppet CA: puppet4.athome.priv
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFgjCCA2qgAwIBAgIBAzANBgkqhkiG9w0BAQsFADApMScwJQYDVQQDDB5QdXBw
ZXQgQ0E6IHB1cHBldDQuYXRob21lLnByaXYwHhcNMTUwOTE1MTkyODAwWhcNMjAw
OTE0MTkyODAwWjAhMR8wHQYDVQQDDBZtaWRkbGV3YXJlLmF0aG9tZS5wcml2MIIC
IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA7rrom3DIxEacFT2SIpnlrMDL
UYaE1m0B2IRJb0XFWLAhCjUZO+ImebxVRbxr8Un7hW9oNlgMD6jlYkXsNqFLD2ib
afatD6m5yxUOmoN3xb/b6d78nnL+Ia1BqZPJCGIEN1Pwh+lQMaaHPXl2SDId/qXc
c/a+uqpTStsjTwFT4sAur6GipqEJUhNUJ2D46fsC00IjS3r3XnHONkNUkD+K9h9y
rsWZzBZknv4niD73Pl3yPTD6OG03eQeXnf9je+Gce860PU/ocPPljdLUCj0opTW3
UcgVTkjgmsa7JAtbhQX2QNK62POZfcOnwE1RnAJp1bOuXFbK+MMnf9weC3ou+Mn2
K95yJcZUqXgeqB5I4nBk1zaYYsaIX+qK3c93YgvboquN3xxe3j3nZdkNjYVBxV6n
ZhpT7xeyNkxg8bZDaVYDeBC6wuCrOX6XCgAFO+mnd1rZsC6mU/bEby4x1NJmrBlJ
vVR+xY8qvRnaCTfhJd5bDx7o1r3XN8o9yaA+384qbR2tkdHQAP0S6Af+IP7pjKX4
aN3w8wlyhW1A61xrSNtalltoHRW87+Ls8cwHBDUEngJnNQ+WDbjVaFZmmBHxLwHe
UuqTRVNYVKD+4PWloomwKoJ8mfgrebP5/z32abpihoWeZPnjQOgva8FWoaw/kovV
7aMjKK6TmLX27WEwU1kCAwEAAaOBvDCBuTA3BglghkgBhvhCAQ0EKgwoUHVwcGV0
IFJ1YnkvT3BlblNTTCBJbnRlcm5hbCBDZXJ0aWZpY2F0ZTAOBgNVHQ8BAf8EBAMC
BaAwIAYDVR0lAQH/BBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQC
MAAwHQYDVR0OBBYEFKG/7yqvYPw5pyo0MKxRJGakVC/KMB8GA1UdIwQYMBaAFPhB
3xS4C7HbjQcuV26CT0SoKI5vMA0GCSqGSIb3DQEBCwUAA4ICAQCRDHrCvZRZ5efT
Vj5MdTxv6JRvTJOFslrBCKbgrscThZE55aHSyWtAwpARPFrsQGy9rwjCq33eDe+Y
uk8GtoAhOhnmLzxJx+mPjAjSQNbpXXDH5KgwAtDSQvZQGw+cuqZssI8dfOZVb73J
85n1r75ghDR9vrR90q2HFsIa9lIJeVatAUKrTS4v+0t5NQ4KoSC0lFSlhI+MzD9j
G67ZVoh8yaxFBAo/UZEDB0VquinExv6CAfo/OZrJRinWc9O89tJsRrREgXPNA0DX
PZxeZXKALlwgC0rxUshEIYgy8V3GWk5lUYAWQyhOH6EV5HpdXpB+AuMHi9MdrBl/
bFQvji0lmd4bOncO3rCm5JXXHWJJiHC6oWpp+3UVcgL1LPhgkNnmbKSNZlA2RA3Y
zU/Cn0xdNtQU0xQLHRTSuZKGjRztyy9waORVnNiUyBT1rahEg+T1OuR/CDRYg6pb
NrArSjdejw5CjFXqq3vCnTv4AvhP2LUU0Bb8e8mkr7KZAexhGAzL7lXNRRsIbr+2
5QPg5LzN4o6ivAmUzkp6wOjNujyelApu5yGd+78smveZvjjShQEU2EtwEjZuFVbk
JSw8Rl2grGKCoEyAHd0NEXlUQwSLN7UID8DtkdvaOUsuxlAzjN4HKWLeCF9hLnNu
sVeVB08LqTRrlg+2lEWbU+yVP0D2Og==
-----END CERTIFICATE-----
subject=/CN=middleware.athome.priv
issuer=/CN=Puppet CA: puppet4.athome.priv
---
Acceptable client certificate CA names
/CN=Puppet CA: puppet4.athome.priv
Client Certificate Types: RSA sign
Server Temp Key: ECDH, secp256k1, 256 bits
---
SSL handshake has read 3664 bytes and written 3693 bytes
---
New, TLSv1/SSLv3, Cipher is ECDHE-RSA-AES256-SHA
Server public key is 4096 bit
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : SSLv3
    Cipher    : ECDHE-RSA-AES256-SHA
    Session-ID: 2CF10CA854510B10393A73714FB62CBB05FAE4E228251362E81E524D1AFE4075
    Session-ID-ctx: 
    Master-Key: 80310E384EF7ABB8AE5F7C9121536BD200B81ECFAA97644CDFF0D07885878876A26D4138591B713D6933A48E1C70A63B
    Key-Arg   : None
    PSK identity: None
    PSK identity hint: None
    Start Time: 1442665897
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
---
QUIT
DONE
root@puppet4:~#
```

Of course this is not acceptable for me because I don't
want to allow sslv3 connections but it's just to eliminate
the possibility of a bad installation of the "new" openssl
version.


