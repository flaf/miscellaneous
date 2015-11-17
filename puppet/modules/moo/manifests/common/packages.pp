class moo::common::packages {

 ensure_packages( [
                   'python-sqlalchemy',
                   'python-mysqldb',
                  ],
                  { ensure => present, }
                )

}


