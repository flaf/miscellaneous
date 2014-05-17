class samba4 {

  mount { 'root_fs':
    name     => '/',
    ensure   => mounted,
    options  => 'noatime,user_xattr,acl,errors=remount-ro',
    remounts => true,
  }

}
