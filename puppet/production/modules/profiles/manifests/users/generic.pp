class profiles::users::generic ( $stage = 'basis', ) {

  $users = hiera_hash('users')
  validate_non_empty_data($users)

  # Installation of sudo if not yet done.
  ensure_packages(['sudo', 'vim'], { ensure => present, })

  # The handle of the root account is specific.
  # Just its password is managed.
  if has_key($users, 'root') {
    $root = $users['root']
    if has_key($root, 'password') {
      user { 'root':
        password => $root['password'],
      }
    }
  }

  $hash = str2hash(inline_template('
    <%-
      users        = @users
      users_hash   = {}
      sshkeys_hash = {}
      vimrc_hash   = {}
      bashrc_hash  = {}

      users.each do |user,properties|
        users_hash[user] = {}
        properties.each do |property,value|
          if property == "ssh_authorized_keys"
            properties["ssh_authorized_keys"].each do |id,attrs|
              idkey = id + "/" + user
              sshkeys_hash[idkey] = attrs
              sshkeys_hash[idkey]["user"] = user
              if sshkeys_hash[idkey].has_key?("key")
                sshkeys_hash[idkey]["key"].gsub!(/( |\n)/, "")
              end
            end
          elsif property == "vimrc"
            if user == "root"
              file = "/root/.vimrc"
            else
              file = "/home/" + user + "/.vimrc"
            end
            vimrc_hash[file] = {
             "ensure"  => "present",
             "owner"   => user,
             "group"   => user,
             "mode"    => "0644",
             "content" => properties["vimrc"].join("\n"),
            }
          elsif property == "bashrc"
            bashrc_hash[user] = properties["bashrc"]
          elsif property == "sudo_access"
            if value == true
              users_hash[user]["groups"] = ["sudo"]
            end
          else
            users_hash[user][property] = value
          end
        end
      end
      users_hash.delete("root")
      hash = {
        "users"   => users_hash,
        "sshkeys" => sshkeys_hash,
        "vimrc"   => vimrc_hash,
        "bashrc"  => bashrc_hash,
      }
    -%>
    <%= hash.to_s %>
  '))

  if versioncmp($puppetversion, '3.6') >= 0 {
    $purge_ssh_keys = true
  } else {
    $purge_ssh_keys = undef
  }

  $users_default = {
    ensure         => present,
    managehome     => true,
    purge_ssh_keys => $purge_ssh_keys,
    shell          => '/bin/bash',
    system         => false,
  }

  create_resources('user', $hash['users'], $users_default)
  create_resources('ssh_authorized_key', $hash['sshkeys'])
  create_resources('file', $hash['vimrc'])
  create_resources('::bash::bashrc', $hash['bashrc'])

}


