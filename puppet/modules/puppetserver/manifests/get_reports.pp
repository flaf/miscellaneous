class puppetserver::get_reports (
  String[1] $file = '/root/reports',
) {

  $query = 'reports[certname, receive_time, logs, metrics, noop] {order by certname, receive_time desc}'
  $array = puppetdb_query($query)

  # We remove reports with the same node (ie same certname).
  $reports = $array.reduce([]) |$memo, $entry| {

    $certname          = $entry['certname']
    $previous_certname = case $memo[-1] =~ Undef {
      true:    { ''                    }
      default: { $memo[-1]['certname'] }
    }

    case $certname == $previous_certname  {
      true:    { $memo              }
      default: { $memo + [ $entry ] }
    }

  }

  file { $file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '600',
    content => epp('puppetserver/reports.epp', { 'reports' => $reports })
  }

}


