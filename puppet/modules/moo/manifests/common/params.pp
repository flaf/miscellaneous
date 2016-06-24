# In this module, the moo::common class is declared as
# resource-like declaration in the other modules and it's
# not really a public class. But it can be useful to have
# data binding with this class too. It can be useful in a
# "role" class to have moobot configuration in a unique
# place.
class moo::common::params (
  Moo::MoobotConf  $moobot_conf,
) {

}


