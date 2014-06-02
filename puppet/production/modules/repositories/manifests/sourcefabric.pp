# ==Action
# Source the Debian repository of sourcefabric (airtime).
# http://apt.sourcefabric.org
#
#
#==Hiera
#
#repositories:
#  sourcefabric:
#    url: 'http://url.of.sourcefabric/repo'
#    key: 'http://url.of.sourcefabric/repo/sourcefabric.gpg'
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



