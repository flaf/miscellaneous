class roles::generic::params (
  Array[String[1]] $supported_classes = $::roles::generic::defaults::supported_classes,
  Array[String[1]] $excluded_classes  = $::roles::generic::defaults::excluded_classes,
  Array[String[1]] $included_classes  = $supported_classes,
) inherits ::roles::generic::defaults {
}


