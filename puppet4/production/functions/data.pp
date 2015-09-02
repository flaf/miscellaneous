function environment::data {


  {
    'toto' => 'aaa',
    'titi' => 'bbb',
    #'network::interfaces::restart_network' => false,
    #network::interfaces::interfaces      => $v
    'network::interfaces::interfaces'      => {
                                              'ethENV' => {
                                                          'method' => 'dhcp',
                                                        },
                                            },
  }

}


