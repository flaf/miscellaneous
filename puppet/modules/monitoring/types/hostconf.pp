type Monitoring::HostConf = Struct[{
  'host_name'        => Monitoring::Hostname,
  'address'          => Monitoring::Address,
  'templates'        => Array[Monitoring::Template, 1],
  'custom_variables' => Array[Monitoring::CustomVariable],
  'extra_info'       => Monitoring::ExtraInfo,
  'monitored'        => Boolean,
}]

# Note: this type is almost the same as the
# Monitoring::CheckPoint except that:
#
#   * The "address" key is not optional.
#   * The "templates" key is not optional and can't be an empty array.
#   * The "custom_variables" key is not optional (but can be an empty array).
#   * The "extra_info" key is not optional (but can be an empty hash).
#   * The "monitored" key is not optional.


