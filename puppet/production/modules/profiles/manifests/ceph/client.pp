class profiles::ceph::client {

  require '::profiles::ceph::params'

  $ceph_conf    = $::profiles::ceph::params::ceph_conf
  $cluster_name = $::profiles::ceph::params::cluster_name
  $cluster_tag  = $::profiles::ceph::params::cluster_tag
  $keyrings     = $ceph_conf['client']['keyrings']

  # Test if the data has been well retrieved.
  validate_non_empty_data($keyrings)
  validate_hash($keyrings)

  $client_resources = str2hash(inline_template('
    <%-
      keyrings = @keyrings
      hash = {}
      keyrings.each do |account,properties|
        hash[cluster_name + "-" + account] = {
          "cluster_name" => @cluster_name,
          "magic_tag"    => @cluster_tag,
          "account"      => account,
          "owner"        => properties["owner"],
          "group"        => properties["group"],
          "mode"         => properties["mode"],
        }
      end
    -%>
    <%= hash.to_s %>
  '))

  create_resources('::ceph::client', $client_resources)

}


