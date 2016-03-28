type Puppetforge::Sshkeypair = Optional[
  Struct[ 
    { 
      'pubkey'  => String[1],
      'privkey' => String[1],
    }
  ]
]


