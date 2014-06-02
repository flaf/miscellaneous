class repositories::nunkis ($stage = repository) {
	realize (Debian::Apt::Sources::Key['crdp'])

	debian::apt::sources::repository { "nunkis":
		url          => "http://debian-repository.crdp.ac-versailles.fr/debian",
		distribution => "${lsbdistcodename}-nunkis",
		components   => "main",
	}

	debian::apt::sources::preferences { 'nunkis':
		package_name  => '*',
		pin           => "release n=${lsbdistcodename}-nunkis",
		priority      => 990,
	}
}
