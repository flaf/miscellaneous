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


$a = ::network::get_matching_network('10.0.2.5/8')
notify { 'Test': message => "[${a}]" }


