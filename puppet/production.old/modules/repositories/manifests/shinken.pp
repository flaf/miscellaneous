class repositories::shinken ($stage = repository) {

	# With this line, wopr-[1-6] failed to realize
	# the Debian::Apt::Sources::Key['crdp'] resource.
	include debian::apt::sources

	realize (Debian::Apt::Sources::Key['crdp'])

	debian::apt::sources::repository { 'shinken':
		url          => 'http://debian-repository.crdp.ac-versailles.fr/debian',
		distribution => 'shinken',
		components   => "main",
	}
}
