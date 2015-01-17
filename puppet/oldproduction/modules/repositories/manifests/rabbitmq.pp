class repositories::rabbitmq ($stage = repository) {
	debian::apt::sources::key { 'rabbitmq':
		source => 'http://www.rabbitmq.com/rabbitmq-signing-key-public.asc',
	}

	debian::apt::sources::repository { "rabbitmq":
		url          => 'http://www.rabbitmq.com/debian/',
		distribution => 'testing',
		components   => 'main',
	}
}
