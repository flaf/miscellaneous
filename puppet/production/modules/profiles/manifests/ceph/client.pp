class profiles::ceph::client {

  require '::profiles::ceph::params'

  $ceph_conf     = $::profiles::ceph::params::ceph_conf
  $common        = $::profiles::ceph::params::common
  $keyrings      = $::profiles::ceph::params::keyrings
  $keyrings_used = $ceph_conf['client']['keyrings']

  # Test if the data has been well retrieved.
  validate_non_empty_data($keyrings_used)
  validate_hash($keyrings_used)

  $client_resources = str2hash(inline_template('
    <%-
      keyrings_used = @keyrings_used
      keyrings      = @keyrings
      cluster_name  = @common["cluster_name"]
      hash = {}

      keyrings_used.each do |account,p|
        hash[cluster_name + "-" + account] = {
          "account"    => account,
          "owner"      => p["owner"],
          "group"      => p["group"],
          "mode"       => p["mode"],
          "key"        => keyrings[account]["key"],
          "properties" => keyrings[account]["properties"],
        }
      end
    -%>
    <%= hash.to_s %>
  '))

  create_resources('::ceph::client', $client_resources, $common)

}


