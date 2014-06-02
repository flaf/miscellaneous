class repositories::squeeze_backports ($stage = repository) {
	debian::apt::sources::repository { "squeeze_backports":
		url          => "http://backports.debian.org/debian-backports",
		distribution => "squeeze-backports",
		components   => "main",
	}
}
