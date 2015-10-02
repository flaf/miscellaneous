# ==Action
# Source the Debian repository of: hwraid.le-vert.net
# http://hwraid.le-vert.net/wiki/DebianPackages
#
class repositories::le_vert ($stage = repository) {

  $repositories = hiera_hash('repositories')
  $le_vert      = $repositories['le_vert']
  $url          = $le_vert['url']
  $key          = $le_vert['key']

  debian::apt::sources::key { 'le-vert':
    source => $key,
  }

  debian::apt::sources::repository { 'le-vert':
    url        => $url,
    components => 'main',
  }

}


