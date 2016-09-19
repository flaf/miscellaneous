function roles::wrap_cron_mon (
  Variant[String[1], Undef] $command,
  String[1]                 $name,
) {

  # a) $command is the command which will monitored.
  # b) $name is just the internal name of the check (in /usr/local/cron-status/).
  #
  # If $command is undef, then just the part without the
  # command is returned.

  if $command =~ Undef {
    "/usr/bin/save-cron-status --name ${name} --"
  } else {
    "/usr/bin/save-cron-status --name ${name} -- ${command}"
  }

}


