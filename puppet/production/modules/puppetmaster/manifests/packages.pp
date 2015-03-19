class puppetmaster::packages {

  private("Sorry, ${title} is a private class.")

  $packages = [
                'puppetmaster-passenger',
                'puppetdb',
                'puppetdb-terminus',
                'postgresql',
                'postgresql-contrib',
              ]

  ensure_packages($packages, { ensure => present, })

}


