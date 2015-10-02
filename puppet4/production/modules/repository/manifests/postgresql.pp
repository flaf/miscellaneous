class repository::postgresql (
  String[1]           $url,
  Boolean             $src,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $key = 'B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'

  apt::source { 'postgresql':
    comment     => 'PostgreSQL Repository.',
    location    => "${url}",
    release     => "${::lsbdistcodename}-pgdg",
    repos       => 'main',
    key         => $key,
    include_src => $src,
  }

}


