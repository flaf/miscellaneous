class test (
  $param1,
  $param2 = 'default2',
) {

  $t1 = 'azerty'

  $msg = @("END")

    param1 => ${param1}
    param2 => ${param2}
    | END

  notify { 'test':
    message => $msg,
  }

}


