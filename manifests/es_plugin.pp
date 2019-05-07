define mozart::es_plugin ($path) {
  exec { "es-install-${name}":
    path => ["/usr/share/elasticsearch/bin", "/bin", "/usr/bin", "/usr/sbin", "/sbin"],
    command => "plugin --install ${path}",
    unless => "plugin --list | grep -q '${name}'",
  }
}
