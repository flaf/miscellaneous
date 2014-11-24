# Classes: debian::apt::cron

class debian::apt::cron {
	package { "cron-apt":
		ensure => present,
	}

	file { "/etc/cron-apt/config":
		content => template("debian/cron-apt-config.erb"),
		require => Package["cron-apt"],
	}

	if $debian_apt_cron {
		$apt_cron_time = param2array($debian_apt_cron)
	} else {
		$apt_cron_hour = generate('/usr/bin/env', 'sh', '-c', "echo -n $ipaddress |awk -F. '{ printf \$3 % 6 }'")
		$apt_cron_min  = generate('/usr/bin/env', 'sh', '-c', "echo -n $ipaddress |awk -F. '{ printf \$4 % 60 }'")
	}

	file { "/etc/cron.d/cron-apt":
		content =>template("debian/cron-apt-cron.erb"),
		require => Package["cron-apt"],
	}

	file { "/etc/cron-apt/action.d/5-install":
		ensure  => $debian_apt_cron_auto_upgrade ? {
			'yes' => present,
			default => absent,
		},
		source  => "puppet:///modules/debian/cron-apt-action-upgrade",
		require => Package["cron-apt"],
	}
}

