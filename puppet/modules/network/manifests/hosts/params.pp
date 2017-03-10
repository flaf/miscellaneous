class network::hosts::params (
  Hash[ String[1], Array[String[1],1] ] $entries            = {},
  Hash[ String[1], Array[String[1],1] ] $entries_completed  = ::network::complete_hosts_entries($entries),
  String                                $hosts_from_tag     = '',
  Array[String[1], 1]                   $supported_distributions,
) {
}


