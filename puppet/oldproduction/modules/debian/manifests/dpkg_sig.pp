class debian::dpkg_sig {
	package { 'dpkg-sig':
		ensure => present,
	}
}
