### This file is managed by Puppet, please don't edit it. ###

# Typically during this stage there are:
# - management of the root password,
# - creation of another administrator accounts,
# - management of public ssh keys,
# - and that's all!
#
# This stage is the first stage because it contains the
# management of the root account (especially the root
# password). For instance, in a file resource, if you just
# have "owner => 'root'", the resource must be managed after
# the root user resource (this is involved just by the
# simple presence of 'root' in the "owner" attribute). So
# you can imagine that the root user resource must be
# managed before lot of file resources. So it's a good idea
# to put this stage at the first place.
stage { 'basis':
  before => Stage['repository'],
}

# Typically during this stage there are:
# - management of APT repositories,
# - and that's all!
#
# We must put this stage before the "network" stage because
# in the "network" stage it's possible to have packages
# installations (for instance the "vlan" package or
# sometimes "unbound" etc). So it's safer to manage the APT
# configuration before the "network" stage. Normally, this
# is not a problem because, even if the network is not yet
# configured during this stage, when you run the puppet
# agent for the first time, you have generally already a
# valid network configuration which allows the node to reach
# Internet.
stage { 'repository':
  before => Stage['network'],
}

# Typically during this stage:
# - management of the /etc/network/interfaces file,
# - management of the /etc/revsolv.conf file,
# - management of the /etc/hosts file,
# - management of the ntp service,
# - and that's all!
#
# And the "network" stage which is naturally placed before
# the built-in "main" stage.
stage { 'network':
  before => Stage['main'],
}


# /!\ WARNING /!\
# We do not want to have automatic removes of packages
# during then installation of another package (because of
# conflicts between packages etc).
if $::facts['os']['family'].downcase == 'debian' {

  # It's possible to put this in /etc/apt/apt.conf.d/80no-revmove:
  #
  #   APT::Get::Remove false;
  #
  # But, in this case, the setting is enabled too for the
  # admins during command lines etc. which could be not
  # handy. The setting below will be available during puppet
  # runs only.
  Package {
    install_options => [ '--no-remove' ],
  }

} else {

  $a_family = $::facts['os']['family']

  @("END").regsubst('\n', ' ', 'G').fail
    site.pp: package resource must be defined by default to be
    unable to remove packages during an installation. This is
    not the case with this current node. Update the code of
    `site.pp` to implement this setting with the OS family of
    this current node (ie $a_family).
    |- END

}


# We assume that the $::included_classes variable must
# be defined by the ENC and must be a non-empty array of
# element with this form:
#
#   [ '<author>', '<fully-qualified-class-name>' ]
#
# Yes, each element is an array. For instance:
#
#   $::included_classes = [
#                          ['bob', '::apache2::vhosts' ],
#                          ['joe', '::rsyslog' ],
#                         ]
#
# where, in this case, the classes `::apache2::vhosts`
# and `::rsyslog` will be included to the catalogue
# from the modules `bob-apache2` and `joe-rsyslog`.


if $::included_classes =~ Array[Array[String[1], 2, 2], 1] {

  $::included_classes.each |$author_class| {

    $the_class = $author_class[1]
    include $the_class

  }

} else {

  $msg_not_defined = @(END).regsubst('\n', ' ', 'G')
      Sorry, the node must have a `$::included_classes` global
      variable defined (for instance by the ENC) and it must be
      an non-empty array of elements with this form
      `[ '<author>', '<fully-qualified-class-name>' ]`
      |- END
  fail($msg_not_defined)

}


