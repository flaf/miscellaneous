define ppbackup::ssh_authorized_key (
  String[1] $keyname = $title,
  String[1] $type = 'ssh-rsa',
  String[1] $key,
) {

  include '::ppbackup'

  ssh_authorized_key { "ppbackup~${keyname}":
    user => 'ppbackup',
    type => $type,
    # To allow a key in hiera with multilines with ">".
    key  => $key.regsubst(' ', '', 'G').strip,
  }

}


