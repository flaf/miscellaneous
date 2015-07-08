stage { 'basis': }
stage { 'network': }
stage { 'repository': }

Stage['basis'] -> Stage['network']
               -> Stage['repository']
               -> Stage['main']

# We assume that the $::role variable is already defined
# by the ENC and must be a non empty string.
if $::role =~ String[1] {
  include "${::role}"
} else {
  fail(regsubst(@(END), '\n', ' ', 'G'))
    Sorry, the node must have a `$role` global variable defined
    and it must be a non empty string.
    |- END
}

include '::network::interfaces'

class { 'test':
  a_hash   => { 'a' => 'A', 'b' => 'B', },
  an_array => [ 'a', 'b', 'c' ],
  a_string => 'old',
}


