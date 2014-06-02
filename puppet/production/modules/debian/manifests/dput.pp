class debian::dput {
	package { 'dput':
		ensure => present,
	}

	#define configure ($path, $target, $user, $dput_method, $login, $incoming) {
	define configure ($filename, $sections) {
		file { "dputs-create-cf-${section}":
			content => template('debian/dot.dput.cf.erb'),
			path    => $filename,
			owner   => $user,
		}
	}
}

