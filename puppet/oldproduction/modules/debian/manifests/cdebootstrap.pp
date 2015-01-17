class debian::cdebootstrap {
	package { 'cdebootstrap':
		ensure => present,
	}
}
