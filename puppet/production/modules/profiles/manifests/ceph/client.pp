class profiles::ceph::client {

  require '::profiles::ceph::params'

  $ceph_conf    = $::profiles::ceph::params::ceph_conf
  $cluster_name = $::profiles::ceph::params::cluster_name
  $cluster_tag  = $::profiles::ceph::params::cluster_tag
  $accounts     = $ceph_conf['client']['accounts']

  # Test if the data has been well retrieved.
  validate_non_empty_data($accounts)
  validate_array($accounts)

  $client_resources = str2hash(inline_template('
    <%-
      accounts = @accounts
      hash = {}
      accounts.each do |account|
        hash[cluster_name + "-" + account] = {
          "cluster_name" => @cluster_name,
          "magic_tag"    => @cluster_tag,
          "account"      => account,
        }
      end
    -%>
    <%= hash.to_s %>
  '))

  create_resources('::ceph::client', $client_resources)

}


