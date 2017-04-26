define httpproxy::pgppublickeyfile (
  String[1] $filename = $title,
  String[1] $id,
  String[1] $content,
) {

  include '::httpproxy::params'
  [$keydir] = Class['httpproxy::params']

  file {
    default:
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    ;
    "${keydir}/${name}.pgp":
      content => $content,
    ;
    "${keydir}/${id}":
      ensure => 'link',
      target => "${name}.pgp",
    ;
  }

}


