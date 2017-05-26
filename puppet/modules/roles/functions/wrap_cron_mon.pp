function roles::wrap_cron_mon (
  String[1]                 $name,
  Variant[String[1], Undef] $command = undef,
) {

  # a) $name is just the internal name of the check (in /usr/local/cron-status/).
  # b) $command is the command which will monitored.
  #
  # If $command is undef, then just the part without the
  # command is returned.

  if $command =~ Undef {
    "/usr/bin/save-cron-status --name ${name} --"
  } else {
    "/usr/bin/save-cron-status --name ${name} -- ${command}"
  }

}


