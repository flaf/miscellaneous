# Module description

This module contains some homemade and various functions.


# `is_supported_distrib()` function

Typical example of usage:

```puppet
class foo {

  # The classic "prefix call".
  ::homemade::is_supported_distrib(['truty', 'jessie'], $title)

  # You can use the "chained call" if you prefer.
  # It's completely equivalent :
  #
  #     ['truty', 'jessie'].::homemade::is_supported_distrib($title)
  #

  # The rest of the class.
  ...

}
```

The function raises an error if the distribution of the
current node is not present in the array of the first
argument, else the function does nothing. The function
uses the `lsbdistcodename` fact to know the distribution
of the node and the comparisons are case sensitive.

The second argument is just to give to the function the
name of the class that invokes the function to provide
an explicit error message if the function fails.


# `ljust()` and `rjust()` functions

Examples of usage:

```puppet
# Will return => '     hello'
$v = ::homemade::rjust('hello', 10, ' ')
$v = 'hello'.::homemade::rjust(10, ' ')

# Will return => 'hello     '
$v = ::homemade::ljust('hello', 10, ' ')
$v = 'hello'::homemade::ljust(10, ' ')
```

These functions are just wrappers of the `ljust()` and
`rjust()` ruby methods, except that:
* the first argument must be a non-empty string,
* the second argument must be an integer `> 0`,
* the third argument must be a non-empty string.


# `is_clean_arrayofstr()` and `is_clean_hashofstr()` functions

Examples:

```puppet
# Will return => false
$v = ::homemade::is_clean_arrayofstr( ['aaa', 'bbb', 1234] )

# Will return => true
$v = ::homemade::is_clean_hashofstr( { 'a' => '1', 'b' => '2' } )
```

These functions can take *anything* as argument. `is_clean_arrayofstr`
will return `true` if the argument is an non-empty array of non-empty
string(s), else it will return `false`. `is_clean_hashofstr` will
return `true` if the argument is an non-empty hash of non-empty
string(s) for the keys *and* the values, else it will return `false`.


# `deep_dup()` function

This function will be useful only in the context of a ruby
function. Here is an example:

```ruby
Puppet::Functions.create_function(:'module::foo') do

  dispatch :foo do
    required_param 'Hash[String[1], String[1], 1]', :a_hash
  end

  def foo(a_hash)

    a_hash_copy = call_function('::homemade::deep_dup', a_hash)

    # Code to change the `a_hash_copy` variable.
    # ...

    modified_a_hash_copy

  end

end
```

This function takes one argument which can be:

- a string,
- an integer,
- a float,
- a hash or an array of the previous types above,
- a hash or an array of the previous types above,
- a hash or an array of the previous types above,
- etc.

The function returns a copy of the argument. The copy is
completely independent on the original object. It can be
useful in a ruby function to avoid to change the state of
variables defined in puppet manifests and given as arguments
of the current function, like the `a_hash` variable in the
example above. Indeed, without precaution, if the `a_hash`
variable is modified in the body of the `foo` function, the
value of the `$a_hash` variable *in the calling manifest*
will be modified too. With ruby functions in Puppet,
variables can be mutable which is not the Puppet philosophy.
See [PUP-4825](https://tickets.puppetlabs.com/browse/PUP-4825)
for more explanations.




# `fail_if_undef()` function

Here is a typical example:

```puppet
class foo {

  $var = $::foo::params::var

  ::homemade::fail_if_undef($var, 'foo::params::var', $title)

}
```

If `$var` is `undef` then the function just fails with a
friendly error message given the name of the current class
(with the `$title` parameter) and the name of the variable
(the second parameter). If `$var` is not `undef`, the
function does absolutely nothing.




