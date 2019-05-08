#####################################################
# hysds_cluster_node class
#####################################################

class hysds_cluster_node inherits scientific_python {

  #####################################################
  # add swap file 
  #####################################################

  swap { '/mnt/swapfile':
    ensure   => present,
  }


  #####################################################
  # copy user files
  #####################################################

  file { "/home/$user/.bash_profile":
    ensure  => present,
    content => template('hysds_cluster_node/bash_profile'),
    owner   => $user,
    group   => $group,
    mode    => 0644,
    require => File_line["user_source_anaconda"],
  }


  #####################################################
  # install packages
  #####################################################

  package {
    'mailx': ensure => present;
  }


  #####################################################
  # systemd daemon reload
  #####################################################

  exec { "daemon-reload":
    path        => ["/sbin", "/bin", "/usr/bin"],
    command     => "systemctl daemon-reload",
    refreshonly => true,
  }

  
  #####################################################
  # get integer memory size in MB
  #####################################################

  if '.' in $::memorysize_mb {
    $ms = split("$::memorysize_mb", '[.]')
    $msize_mb = $ms[0]
  }
  else {
    $msize_mb = $::memorysize_mb
  }


  #####################################################
  # disable transparent hugepages for redis
  #####################################################

  file { "/etc/tuned/no-thp":
    ensure  => directory,
    mode    => 0755,
  }


  file { "/etc/tuned/no-thp/tuned.conf":
    ensure  => present,
    content => template('hysds_cluster_node/tuned.conf'),
    mode    => 0644,
    require => File["/etc/tuned/no-thp"],
  }

  
  exec { "no-thp":
    unless  => "grep -q -e '^no-thp$' /etc/tuned/active_profile",
    path    => ["/sbin", "/bin", "/usr/bin"],
    command => "tuned-adm profile no-thp",
    require => File["/etc/tuned/no-thp/tuned.conf"],
  }


  #####################################################
  # tune kernel for high performance redis
  #####################################################

  file { "/usr/lib/sysctl.d":
    ensure  => directory,
    mode    => 0755,
  }


  file { "/usr/lib/sysctl.d/redis.conf":
    ensure  => present,
    content => template('hysds_cluster_node/redis.conf.sysctl'),
    mode    => 0644,
    require => File["/usr/lib/sysctl.d"],
  }

  
  exec { "sysctl-system":
    path    => ["/sbin", "/bin", "/usr/bin"],
    command => "/sbin/sysctl --system",
    require => File["/usr/lib/sysctl.d/redis.conf"],
  }


}
