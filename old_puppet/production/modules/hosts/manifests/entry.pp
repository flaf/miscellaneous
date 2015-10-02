# A user defined class to manage a host entry in the
# /etc/hosts files.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib and homemade_functions
# modules.
#
# == Parameters
#
# *address:*
# A string which must be an IP address. The string can contain
# specific substrings like @ipaddress etc. which will be
# expanded. After expand, the parameter must be a valid IP
# address. This parameter is mandatory, no default value.
#
# *hostnames:*
# An array of at least one hostname associated to the address.
# This parameter is mandatory, no default value.
#
# *exported:*
# A boolean to tell if the hosts entry must be exported
# or not. This parameter is optional and the default
# value is false (ie not exported). If this parameter is
# set to true, you must provide the magic_tag parameter.
#
# *magic_tag:*
# If you set the "exported" parameter to true, you must
# provide this parameter. This parameter must be a string
# to tag the hosts entry. Impossible to use directly the
# metaparameter "tag" because strings like "@datacenter-foo"
# are invalid tag for puppet. On the contrary, this string
# is valid for the magic_tag parameter and will be expanded.
# This parameter is optional and the default value is undef.
#
# == Sample Usages
#
#  '::hosts::entry' { 'self':
#    address   => '@ipaddress',
#    hostnames => [ '@fqdn' ],
#  }
#
# or
#
#  $tag = '@datacenter-cluster-foo'
#
#  '::hosts::entry' { 'self':
#    address   => '@ipaddress',
#    hostnames => [ '@fqdn' ],
#    exported  => true,
#    magic_tag => $tag,
#  }
#
#  class { '::hosts::collect':
#    magic_tag => $tag,
#  }
#
define hosts::entry (
  $address,
  $hostnames,
  $exported  = false,
  $magic_tag = undef,
) {

  require '::hosts'

  ### Checking of the $exported parameter. ###
  validate_bool($exported)

  if $exported {

    if $magic_tag == undef {
      fail("hosts::entry ${title}, `exported` parameter is set to true \
but no magic_tag is defined for this resource.")
    }

    # In this module, $magic_tag must be a string.
    validate_string($magic_tag)

    # "@xxx" variables are allowed in $magic_tag string.
    $tag_expanded = inline_template(str2erb($magic_tag))

  }

  ### Checking of the $address parameter. ###
  validate_string($address)

  if empty($address) {
    fail("hosts::entry ${title}, `address` parameter must be a non \
empty string.")
  }

  $addr = inline_template(str2erb($address))

  unless is_ip_address($addr) {
    fail("hosts::entry ${title}, `address` parameter must be an IP address \
after expansion.")
  }


  ### Checking of the $hostnames parameter. ###
  unless is_array($hostnames) {
    fail("hosts::entry ${title}, `hostnames` parameter must be an array.")
  }

  if empty($hostnames) {
    fail("hosts::entry ${title}, `hostnames` parameter must be an non \
empty array.")
  }

  $hosts_array = str2array(inline_template('
    <%-
      hosts_array = []
      title = @title
      @hostnames.each do |hostname|
        unless hostname.is_a?(String) and not hostname.empty?
          msg = "hosts::entry #{title}, `hostnames` parameter must be an "
          msg += "array of non empty strings."
          scope.function_fail([msg])
        end
        erb = scope.function_str2erb([hostname])
        hosts = scope.function_inline_template([erb]).downcase
        unless hosts =~ /^[-_.0-9a-z]+$/
          msg = "hosts::entry #{title}, in `hostnames` parameter, the "
          msg += "`#{hostname}` element seems to be an invalid host name."
          scope.function_fail([msg])
        end
        hosts_array.push(hosts)
      end
    -%>
    <%= hosts_array.to_s %>
  '))


  # Building of the hosts entry string.
  $hostnames_str   = join($hosts_array, ' ')
  $hosts_entry_str = "${addr} ${hostnames_str}\n"

  if $exported {
    # If the resource is exported, we insert the fqdn
    # in the file name to avoid duplicated resources.
    @@file { "/etc/hosts.puppet.d/${::fqdn}--${title}.conf":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $hosts_entry_str,
      tag     => $tag_expanded,
    }
  } else {
    file { "/etc/hosts.puppet.d/${title}.conf":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $hosts_entry_str,
      notify  => Class['::hosts::refresh'],
    }
  }

}


