# Puppet class to manage kernel boot options in the /etc/default/grub file.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib.
#
# == Parameters
#
# *kernel_options*
#
# A hash with this form:
#
#  kernel_options = {
#                    'ipv6.disable' => '1',
#                    'foo'          => 'xxx',
#                   }
#
# After any change of kernel boot options, you must
# reboot manually the node to validate the changes.
#
# == Sample Usages
#
#  # No kernel boot option.
#  include '::grub'
#
# or:
#
#  class { '::grub'
#    kernel_options = { 'ipv6.disable' => '1', },
#  }
#
class grub (
  $kernel_options = {}
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  validate_hash($kernel_options)

  # If $kernel_options = { 'name1' => 'val1', ...}, $options will be
  # equal to 'name1=val1 ...'.
  $options = join(join_keys_to_values($kernel_options, '='), ' ')

  file_line { 'ensure-kernel-options':
    path   => '/etc/default/grub',
    line   => "GRUB_CMDLINE_LINUX=\"${options}\"",
    match  => '^GRUB_CMDLINE_LINUX=.*$',
    before => Exec['update-grub'],
    notify => Exec['update-grub'],
  }

  exec { 'update-grub':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'update-grub',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
  }

  file_line { 'test':
    path   => '/tmp/a',
    line   => "aaa=bbb",
    match  => '^aaa=.*$',
  }

}


