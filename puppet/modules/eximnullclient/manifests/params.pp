class eximnullclient::params (
  Eximnullclient::DcSmarthost  $dc_smarthost,
  Eximnullclient::PasswdClient $passwd_client,
  Optional[String[1]]          $redirect_local_mails,
  Boolean                      $prune_from,
  Array[String[1], 1]          $supported_distributions,
) {
}


