class repositories::varnish ($stage = repository) {
	debian::apt::sources::key { "varnish":
		source => "http://repo.varnish-cache.org/debian/GPG-key.txt",
	}

	debian::apt::sources::repository { "varnish":
		url        => "http://repo.varnish-cache.org/debian/",
		components => "varnish-3.0",
	}
}
