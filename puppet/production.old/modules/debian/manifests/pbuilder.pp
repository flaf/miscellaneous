class debian::pbuilder {
	include debian::cdebootstrap

	$pbuilder = hiera_hash('pbuilder')

	package { 'pbuilder':
		ensure => present,
	}

	package { 'git-buildpackage':
		ensure => present,
	}

	exec { 'create-dit-pbuilderrc':
		command => '/usr/bin/touch /root/.pbuilderrc',
		creates => '/root/.pbuilderrc',
	}

	file { '/var/cache/pbuilder/bases':
		ensure  => directory,
		owner   => root,
		group   => root,
		mode    => '0755',
		require => Package['pbuilder'],
	}

	file { '/etc/pbuilderrc':
		content => template('debian/pbuilderrc.erb'),
		owner   => root,
		group   => root,
		mode    => '0644',
	}

	file { '/usr/local/bin/pbuilder-':
		source => 'puppet:///modules/debian/pbuilder-',
		owner  => root,
		group  => root,
		mode   => '0755',
	}

	file { [ '/usr/local/bin/pbuilder-lenny-amd64',   '/usr/local/bin/pbuilder-lenny-i386',
	         '/usr/local/bin/pbuilder-squeeze-amd64', '/usr/local/bin/pbuilder-squeeze-i386',
	         '/usr/local/bin/pbuilder-wheezy-amd64',  '/usr/local/bin/pbuilder-wheezy-i386' ]:
		ensure => link,
		target => '/usr/local/bin/pbuilder-',
	}

	file { '/usr/local/bin/git-pbuilder-squeeze':
		# NB: creating the base<distrib>.cow need /etc/pbuilderrc to be manually modified:
		# sed -i 's/\$DISTRIBUTION/squeeze/g' /etc/pbuilderrc && git-pbuilder-squeeze create
		# (remove the cow image with 'rm -rf rm -rf /var/cache/pbuilder/base-squeeze.cow')
		ensure => link,
		target => '/usr/bin/git-pbuilder',
	}
}
