# Example:
#
#  $h = {
#    'modA::params::a1' => 'A1',
#    'modA::params::a2' => 'A2',
#    'modB::params::b1' => 'B1',
#    'modB::params::b2' => 'B2',
#  }
#
#  $h.reduce2prefix('modA::params')
#
#  will returns:
#
#  {
#    'a1' => 'A1',
#    'a2' => 'A2',
#  }
#
#
function roles::reduce2prefix(
  Hash[String[1], Data] $hash,
  String[1] $prefix,
) >> Hash[String[1], Data] {

  $regex = Regexp.new("^${prefix}::")

  $hash.filter |$k, $v| {$k =~ $regex}.reduce({}) |$memo, $item| {
    [$k, $v] = $item;
    {$k.regsubst($regex, '') => $v}
  }

}


