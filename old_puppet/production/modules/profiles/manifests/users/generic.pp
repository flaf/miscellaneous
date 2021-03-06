# TODO:
#   Create a specific hiera entry "ssh_keys" for
#   the ssh keys (and put $ssh_keys = hiera_hash('ssh_keys')),
#   and in the "users" hiera entry just put the a list of
#   key names per user. For instance:
#
#   ssh_keys:
#     root@router.athome.priv:
#       type: 'ssh-rsa'
#       key: '...'
#     francois@flpc.athome.priv:
#       type: 'ssh-rsa'
#       key: '...'
#
#   users:
#     flaf:
#       password: '...'
#       ssh_authorized_keys:
#         - 'root@router.athome.priv'
#         - 'francois@flpc.athome.priv'
#
#
class profiles::users::generic ( $stage = 'basis', ) {

  $users = hiera_hash('users')
  validate_non_empty_data($users)

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

        if properties.has_key?("home")
          home = properties["home"]
        elsif user == "root"
          home = "/root"
        else
          home = "/home/" + user
        end
        users_hash[user]["home"] = home

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
            file = home + "/" + ".vimrc"
            vimrc_hash[file] = {
             "ensure"  => "present",
             "owner"   => user,
             "group"   => user,
             "mode"    => "0644",
             "content" => properties["vimrc"].join("\n") + "\n\n",
            }
          elsif property == "bashrc"
            bashrc_hash[user] = properties["bashrc"]
            bashrc_hash[user]["home"] = home
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
    tag            => 'user_account',
  }

  create_resources('user', $hash['users'], $users_default)
  create_resources('ssh_authorized_key', $hash['sshkeys'], { tag => 'sshkey', })
  create_resources('file', $hash['vimrc'], { tag => 'vimrc',})
  create_resources('::bash::bashrc', $hash['bashrc'], { tag => 'bashrc',})

  User <| tag == 'user_account' |> -> Ssh_authorized_key <| tag == 'sshkey' |>
                                   -> File <| tag == 'vimrc' |>
                                   -> ::Bash::Bashrc <| tag == 'bashrc' |>

}


