class test (
  $param1,
  $param2 = 'default2',
) {

  $t1 = 'azerty'

  $msg = @("END")

    param1 => ${param1}
    param2 => ${param2}
    | END

  $v = lookup('test::azerty')

  notify { 'test':
    message => $v,
  }

}


