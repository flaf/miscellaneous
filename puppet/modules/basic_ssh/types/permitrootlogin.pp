type Basic_ssh::PermitRootLogin = Enum[
  'yes',
  'without-password',
  'prohibit-password',    # Synonym of 'without-password'.
  'forced-commands-only',
  'no',
]


