class puppetserver::get_reports (
  String[1] $file = '/root/reports',
) {

  $query   = 'reports[certname, receive_time, logs, metrics, noop] {latest_report? = true order by certname}'
  $reports = puppetdb_query($query)

  file { $file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '600',
    content => epp('puppetserver/reports.epp', { 'reports' => $reports })
  }

}


