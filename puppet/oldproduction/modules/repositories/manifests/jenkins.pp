class repositories::jenkins ($stage = repository) {
	debian::apt::sources::key { 'D50582E6':
		source => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
	}

	debian::apt::sources::repository { 'jenkins':
		url          => 'http://pkg.jenkins-ci.org/debian',
		distribution => 'binary/',
		components   => '',
	}
}
