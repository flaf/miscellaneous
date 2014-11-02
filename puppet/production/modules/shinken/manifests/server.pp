#==Action
#
# Install a Shinken server for monitoring.
# Tested with Debian Wheezy.
#
# This class depends on:
# - repositories::shinken to add a repository made in CRDP in the APT configuration.
# - generate_password function to avoid to put clear text passwords in hiera.
#   You can can use clear text passwords or use the __pwd__ syntax in hiera.
#
#
#==Hiera
#
#  # Optional. If not defined, the default value is either 'shinken_tag'
#  # or "shinken_$datacenter" if $datacenter is defined. The shinken server
#  # retrieves the exported files that have this tag and built its configuration
#  # to automatically check some puppet hosts.
#  shinken_tag: 'shinken_foo'
#
#
#  # This entry is optional. The irc bot is a shinken contact
#  # which is created automatically and doesn't belong to this list.
#  shinken_contacts:
#    john:
#      email: 'john@domain.tld'
#      tel: '0676XXXX18'          # Optional.
#      is_admin: 'true'           # Optional. If 'true', the contact see all in the WebUI and can initiate checks manually.
#      htpasswd: 'HRv83Z/f9iJ9Q'  # Optional. This is clear text hash password.
#      password: '__pwd__{"salt" => ["john"], "nice" => true, "max_length" => 4}'  # Optional. This password will be in the shinken
#                                                                                  # configuration in clear text.
#
#  # This entry is optional. Rules to cancel some notifications. The syntax is
#  # explained in the black_list file header in the shinken configuration.
#  shinken_black_list:
#      - '^joe$:.*:^load cpu$'
#      - '^(joe|bob)$:foo-server-[12]:.*'
#
#
#  shinken_misc:
#
#    # Useful if you want to visit the WebUI via a reverse proxy
#    # with this kind of address http://my-reverse-proxy/bar/.
#    # Be careful, the reverse proxy must rewrite the "Location"
#    # header http://my-reverse-proxy/ --> http://my-reverse-proxy/bar/.
#    reverse_proxy: 'true' # Optional. The default value is 'false'.
#    add_in_links: 'bar'   # Optional. The default value is 'shinken'.
#                          # If equal to '_EMPTY_', the WebUI can be directly reachable
#                          # on the port 80 with this address http://shinken.domain.tld.
#
#    url_for_sms: 'http://foo/sendsms.pl' # url used to send SMS.
#    sms_threshold: '3'                   # If the business impact of the check is lower than this value, no SMS.
#    rarefaction_threshold: '7'           # After n notification for the same problem, the notification become rarefied.
#
#    # Used to define the IRC bot contact in shinken.
#    irc_server: 'irc.domain.tld'
#    irc_port: '6667'
#    irc_channel: '#monitoring'
#    irc_password: '__pwd__{"salt" => ["irc"], "nice" => true, "max_length" => 7}'
#
#    # This entry is optional. Useful to add hosts that don't use a puppet
#    # client and that we want to check anyway.
#    manual_hosts:
#      server-1:                            # The host_name in the shinken configuration.
#        address: 'www.server-1.domain.tld' # Required for each manual host (if exists).
#        templates: 'http_tpl,https_tpl'    # Required for each manual host (if exists).
#        custom:                            # Optional. Add customized properties for this host.
#          - '_http_pages ping.php$(vhost.domain.tld!regex)$,'
#          - '_HTTP_WARN 5'
#      google:
#        address: 'www.google.fr'
#        templates: 'http_tpl'
#
#
#  # The all 'ldap' entry is optional. Be careful, if the "monitoring_account"
#  # entry doesn't exist in hiera, shinken doesn't use LDAP for the WebUI
#  # authentification.
#  ldap:
#    basedn: 'dc=domain,dc=tld'
#    uri: 'ldaps://ldap-server.domain.tld'
#    monitoring_account: 'uid=lynx,ou=system,dc=domain,dc=tld'
#    monitoring_password: '__pwd__{"salt" => ["$datacenter", "ldap", "monitoring"], "nice" => true}'
#
#
#  # Below some macros used in parameters by Shinken to run the checks.
#
#
#  # The SNMP configuration of the nodes to check. This entry is required.
#  # The default is SNMPv3 except for the pfsense_tpl which use SNMPv2c.
#  # It's possible to use SNMPv2c for some hosts but you must define
#  # a specific property for these hosts (see the shinken::node class).
#  snmp:
#    secname: '__pwd__{"salt" => ["$datacenter", "snmp-secname"], "nice" => true, "max_length" => 12}'
#    authpass: '__pwd__{"salt" => ["$datacenter", "snmp-authpass"]}'
#    authproto: 'sha'
#    privpass: '__pwd__{"salt" => ["$datacenter", "snmp-privpass"], "nice" => true, "case" => "upper"}'
#    privproto: 'aes'
#    pfsense_community: '__pwd__{"salt" => ["$datacenter", "snmp-pfsense"], "nice" => true}' # Optional.
#
#  # This entry is optional. Of course, you must define it if you want to check FTP.
#  # Default values are '' and ''.
#  ftp:
#    monitoring_account: 'supervision'
#    monitoring_password: '__pwd__{"salt" => ["$datacenter", "ftp", "monitoring"]}'
#
#  # This entry is optional. Of course, you must define it if you want to check IPMI.
#  # Default values are '' and ''.
#  ipmi:
#    monitoring_account: 'supervision'
#    monitoring_password: '__pwd__{"salt" => ["$datacenter", "ipmi", "monitoring"]}'
#
#  # This entry is optional. Of course, you must define it if you want to check Windows.
#  windows:
#    monitoring_account: 'shinken'
#    monitoring_password: '__pwd__{"salt" => ["$datacenter", "windows", "monitoring"]}'
#
#  # This entry is optional. If you want to add macros in shinken configuration,
#  # you can put an hash as below:
#  shinken_additional_macros:
#    MACRO_NAME: 'macro_value'
#    SENSITIVE_MACRO_NAME: '__pwd__{"salt" => ["foo"]}' # You can use the __pwd__ syntax for the value.
#
#
class shinken::server {

  require 'shinken::server::params'

  $reverse_proxy = $shinken::server::params::reverse_proxy

  include 'repositories::shinken'           # Add the shinken repository (made in CRDP).
  include 'shinken::server::install'        # Install all the required packages.
  include 'shinken::server::botirc'         # Manage the botirc configuration.
  include 'shinken::server::config'         # Manage the shinken configuration.
  include 'shinken::server::admin_scripts'  # Install some helpful scripts for the admin.

  # Ordering.
  Class['repositories::shinken']
    -> Class['shinken::server::install']
    -> Class['shinken::server::botirc']
    -> Class['shinken::server::config']
    -> Class['shinken::server::admin_scripts']

  if ($reverse_proxy) {
    # We don't care about ordering for this class.
    include 'shinken::server::reverse_proxy'
  }

}


