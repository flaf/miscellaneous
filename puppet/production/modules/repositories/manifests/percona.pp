class repositories::percona ($stage = repository) {
	debian::apt::sources::gpg_key { 'percona':
		server    => 'hkp://keys.gnupg.net',
		recv_keys => '1C4CBDCDCD2EFD2A',
		keyid     => 'CD2EFD2A',
	}

	debian::apt::sources::repository { "percona":
		url        => "http://repo.percona.com/apt",
		distribution => "squeeze",
		components   => "main",
	}
}
