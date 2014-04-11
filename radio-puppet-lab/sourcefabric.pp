# ==Action
# Source the Debian repository of sourcefabric (airtime).
# http://apt.sourcefabric.org
#
#
#repositories:
#  sourcefabric:
#    url: 'http://flpc/apt-mirror/apt.sourcefabric.org'
#    key: 'http://flpc/apt-mirror/sourcefabric.gpg'
#
#
class repositories::sourcefabric ($stage = repository) {

  $repositories = hiera_hash('repositories')

  $sourcefabric = $repositories['sourcefabric']
  $url          = $sourcefabric['url']
  $key          = $sourcefabric['key']

  debian::apt::sources::key { 'sourcefabric':
    source => $key,
  }

  debian::apt::sources::repository { 'sourcefabric':
    url        => $url,
    components => 'main',
  }

}



