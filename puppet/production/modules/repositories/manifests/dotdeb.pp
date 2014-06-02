class repositories::dotdeb ($stage = repository) {
	debian::apt::sources::key { "dotdeb":
		source => "http://www.dotdeb.org/dotdeb.gpg",
	}

	debian::apt::sources::repository { "dotdeb":
		url        => "http://packages.dotdeb.org",
		components => "all",
	}
}
