define repository::pinning (
  String[1] $id = $title,
  String[1] $explanation,
  String[1] $packages = '*',
  String[1] $version = '',
  Integer   $priority = 0,
) {

  file { "/etc/apt/preferences.d/${id}.pref":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('repository/pinning.epp',
                 {
                  'explanation' => $explanation,
                  'packages'    => $packages,
                  'version'     => $version,
                  'priority'    => $priority,
                 }
               ),
  }

}


