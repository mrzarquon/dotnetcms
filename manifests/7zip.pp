class dotnetcms::7zip {
  
  # This class makes use of the staging::file defined type in order to take
  # advantage of a centrally defined file staging directory. Specifically,
  # $staging::path. In Puppet at the time of writing, however, parse order is
  # important when it comes to defining and using variables. For this class to
  # work as expected, Class['staging'] needs to be parsed *before* this class
  # is. Because of how important this parse order is to expected behavior, a
  # warning will be issued on both the server and agent if this class is parsed
  # before Class['staging'] has been declared.
  #
  # Good: (assume Class['profile::staging'] declares Class['staging'])
  #
  #  include profile::staging
  #  include 7zip
  #
  # Bad:
  #
  #  include 7zip
  #  include profile::staging
  
  file {'C:\staging\7z920-x64.msi':
    ensure => present,
    mode   => 0755,
    source => 'puppet:///modules/dotnetcms/7z920-x64.msi',
  }

  package { '7-Zip':
    ensure  => installed,
    name    => '7-Zip 9.20 (x64 edition)',
    source  => 'C:\staging\7z920-x64.msi',
    require => File['C:\staging\7z920-x64.msi'],
  }

}
