class repositories::webradio ($stage = repository) {

    realize (Debian::Apt::Sources::Key['crdp'])

    debian::apt::sources::repository { 'webradio':
        url          => 'http://debian-repository.crdp.ac-versailles.fr/debian',
        distribution => 'webradio',
        components   => "main",
    }

}


