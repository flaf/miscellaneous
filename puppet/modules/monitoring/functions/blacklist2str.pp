function monitoring::blacklist2str (
  Monitoring::Blacklist $blacklist,
  String                $indent_str = '',
) >> String {

  $params = {
    'blacklist' => $blacklist,
  }

  # We remove the trailing \n.
  $str = inline_epp(@(END), $params).regsubst('\n$', '')
    <%-
        $blacklist.each |$rule| {
          if 'comment' in $rule {
            $rule['comment'].each |$line| {
    -%>
    # <%= $line %>
    <%-
            }
          }
          $contact     = $rule['contact']
          $host_name   = $rule['host_name']
          $description = $rule['description']
          $timeslots   = $rule['timeslots']
          $weekdays    = $rule['weekdays']
    -%>
    <%= "${contact}:${host_name}:${description}:${timeslots}:${weekdays}" %>
    <%-
        }
    -%>
    | END

  $str.regsubst('^', $indent_str, 'G')

}


