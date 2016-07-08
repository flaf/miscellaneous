function roles::wrap_cron_mon (
  String[1] $command,
  String[1] $name,
) {

  "/usr/bin/save-cron-status --name ${name} -- ${command}"

}


