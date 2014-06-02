class repositories::crdp ($stage = repository) {
	realize (Debian::Apt::Sources::Key['crdp'])

	debian::apt::sources::repository { "crdp":
		url          => "http://debian-repository.crdp.ac-versailles.fr/debian",
		distribution => $lsbdistcodename ? {
			squeeze => 'squeeze-crdp',
			default => 'wheezy',
		},
		components   => "main",
	}
}
