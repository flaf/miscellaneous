===============================================
"Source" package of areca-cli for Debian Wheezy
===============================================

Description
===========

This is a (personal) package which provides the areca-cli
command for amd64 to manage Areca RAID controller.

Build the .deb package on Debian Wheezy
=======================================

To build the .deb package on Debian Wheezy, you can run these commands in a shell:

.. code:: sh

  # Creation of the working directory.
  git clone https://github.com/flaf/areca-cli.git
  cd areca-cli/areca-cli

  # Installation of the build-dependencies
  BUILD_DEPENDS='<see the debian/control file>'
  apt-get install --no-install-recommends --yes build-essential $BUILD_DEPENDS

  # Building of the package.
  ./debian/rules create_deb

And the package is in the parent directory:

.. code:: sh

  ls -l ..


