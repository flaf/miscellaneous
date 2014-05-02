=================================================
Source package of botirc-parrot for Debian Wheezy
=================================================

Description
===========

This is a daemon which reads a "fifo" file and just
repeats the text stream in a IRC channel. There is just one
configuration file in **/etc/default/botirc-parrot**
which you can edit like this :

.. code:: sh

 # Set to "YES" if you want to start the daemon.
 START="YES"

 USER="root"
 GROUP="root"

 # Don't forget to create the "fifo" file before.
 PARROT_FIFO="/edit/your/fifo/file/here"

 PARROT_SERVER="irc.freenode.net"
 PARROT_PORT="6667"
 PARROT_CHANNEL="#mychan"
 PARROT_PASSWORD="mypasswd"

And you can start the daemon :

.. code:: sh

 invoke-rc.d botirc-parrot restart

After a few seconds, the service joins the #mychan IRC channel
and then you can send a message with a command like :

.. code:: sh

 echo "Hello, I send a message..." > /edit/your/fifo/file/here



Build the .deb package on Debian Wheezy
=======================================

To build the .deb package on Debian Wheezy, you can run these commands in a shell:

.. code:: sh

  # Creation of the working directory.
  git clone https://github.com/flaf/miscellaneous.git
  cd miscellaneous/debpkg_botirc-parrot/botirc-parrot/

  # Installation of the build-dependencies
  BUILD_DEPENDS='<see the debian/control file>'
  apt-get install --no-install-recommends --yes build-essential $BUILD_DEPENDS

  # Building of the package.
  ./debian/rules create_deb

And the package is in the parent directory:

.. code:: sh

  ls -l ..

