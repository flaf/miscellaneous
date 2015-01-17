class repositories::jrds ($stage = repository) {
	realize (Debian::Apt::Sources::Key['crdp'])

	debian::apt::sources::repository { 'jrds':
		url          => 'http://debian-repository.crdp.ac-versailles.fr/debian',
		distribution => 'jrds',
		components   => "main",
	}
}
