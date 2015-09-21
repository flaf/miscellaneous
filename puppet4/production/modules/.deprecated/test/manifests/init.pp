class test (
  $param1,
  $param2 = 'default2',
) {

  $t1 = 'azerty'

  $msg = @("END")

    param1 => ${param1}
    param2 => ${param2}
    | END

  #$v = lookup('fred', hash, unique, 'eeee') #|$name| { $name = '456'  }
  #$h = hiera_hash('hash-foo')
  #$h = lookup('hash-foo', Hash, hash)

  $h = ::homemade::rjust("aa", 15, '1234567890')

  notify { 'test':
    message => "[${h}]",
  }

  ::homemade::is_supported_distrib([ 'trusty', 'jessie' ], $title )

}


