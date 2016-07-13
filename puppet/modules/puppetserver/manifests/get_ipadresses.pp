class puppetserver::get_ipadresses {

  $query     = 'facts{ name = "ipaddress" }'
  $big_array = puppetdb_query($query)
  $big_hash  = $big_array.reduce({}) |$memo, $entry| {
      $memo + { $entry['certname'] => $entry['value'] }
  }

  $template = @(END)
    <%- |$big_hash| -%>
    <%- $big_hash.keys.sort.each |$fqdn| { -%>
    <%= $fqdn %>:<%= $big_hash[$fqdn] %>
    <%- } -%>
    |- END

  $str = inline_epp($template, { 'big_hash' => $big_hash })

  notice("\n\n${str}")

}


