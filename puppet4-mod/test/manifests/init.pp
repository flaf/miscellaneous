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
  $h = lookup('hash-foo', Hash, hash)

  notify { 'test':
    message => $h,
  }

  ::homemade::is_supp_distrib([ 'trusTy', 'jessie' ], $title )

}


