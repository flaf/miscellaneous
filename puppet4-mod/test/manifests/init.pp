class test ($a_hash, $an_array, $a_string) {

  notify { 'hash-before': message => $a_hash, }
  notify { 'array-before': message => $an_array.join('|'), }
  notify { 'string-before': message => $a_string, }

  ::test::foo($a_hash, $an_array, $a_string)

  notify { 'hash-after': message => $a_hash, }
  notify { 'array-after': message => $an_array.join('|'), }
  notify { 'string-after': message => $a_string, }

}

