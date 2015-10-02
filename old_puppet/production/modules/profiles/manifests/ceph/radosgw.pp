class profiles::ceph::radosgw {

  require '::profiles::ceph::params'

  $common       = $::profiles::ceph::params::common
  $keyrings     = $::profiles::ceph::params::keyrings
  $cluster_name = $common['cluster_name']

  $account = strip(inline_template('
    <%-
      the_account = ""
      keyrings = @keyrings
      keyrings.each do |account,p|
        if p.has_key?("radosgw_host") and p["radosgw_host"] == scope["::hostname"]
          the_account = account
        end
      end
    -%>
    <%= the_account %>
  '))

  if $account == "" {
    fail("Class ${title} problem, no keyring found for this radosgw host.")
  }

  $client_resource = {
    "$cluster_name-$account" => {
       'account'     => $account,
       'owner'       => $keyrings[$account]["owner"],
       'group'       => $keyrings[$account]["group"],
       'mode'        => $keyrings[$account]["mode"],
       'key'         => $keyrings[$account]["key"],
       'properties'  => $keyrings[$account]["properties"],
       'is_radosgw'  => true,
    }
  }

  create_resources('::ceph::client', $client_resource, $common)

}


