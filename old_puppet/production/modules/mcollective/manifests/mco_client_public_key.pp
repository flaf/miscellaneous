define mcollective::mco_client_public_key (
  $id = $title,
  $content,
) {

  file { "/etc/mcollective/ssl/clients/${id}.public.pem":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => $content,
  }

}


