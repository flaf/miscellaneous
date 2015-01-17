class debian::apt::sources ($stage = repository) {
	# Repository and Keys
	define key ($ensure = present, $source) {
		exec { "key-$name":
			command => "/usr/bin/wget $source -O - | /usr/bin/apt-key add -",
			unless  => "/usr/bin/apt-key list | /bin/grep $name",
			notify  => Exec['apt-update'],
		} 
	}

	# Declare some vitual key resources

	@debian::apt::sources::key { 'crdp':
		source => 'http://debian-repository.crdp.ac-versailles.fr/crdp.gpg',
	}

	define gpg_key ($server, $recv_keys, $keyid) {
		exec { "gpg-key-$name":
			command => "/usr/bin/gpg --keyserver $server --recv-keys $recv_keys && /usr/bin/gpg -a --export $keyid | /usr/bin/apt-key add -",
			unless  => "/usr/bin/apt-key list | /bin/grep $keyid",
			notify  => Exec['apt-update'],
		}
	}

	define repository ($ensure = present, $url, $distribution = $lsbdistcodename, $components = "main") {
		file { "/etc/apt/sources.list.d/$name.list":
			content => template("debian/apt-repository.erb"),
			notify  => Exec['apt-update'],
		}
	}

	# preferences
	define preferences ($ensure = present, $package_name = $name, $pin, $priority) {
		file { "/etc/apt/preferences.d/$name.pref":
			content => template("debian/apt-preferences.erb"),
		}
	}

	exec { "apt-update":
		command     => "/usr/bin/aptitude update",
		refreshonly => true,
		returns     => [ 0, 255 ],
	}
}

