class dotnetcms {

  require dotnetcms::7zip
  include dotnetcms::staging
  require dotnetcms::iis

  reboot { 'before':
    when => pending,
  }

  staging::file {'C:\staging\dotNetFx40_Full_x86_x64.exe':
    source => 'http://master/dotnetcms/dotNetFx40_Full_x86_x64.exe',
    before => Package['Microsoft .NET Framework 4 Client Profile'],
  }

  package { 'Microsoft .NET Framework 4 Client Profile':
    ensure          => installed,
    source          => 'C:\staging\dotNetFx40_Full_x86_x64.exe',
    install_options => ['/q', '/norestart'],
    before          => Exec['extract_cms4'],
    notify          => Exec['register_net_with_iis'],
  }
  
  reboot { 'after':
    subscribe => Package['Microsoft .NET Framework 4 Client Profile'],
  }

  exec { 'register_net_with_iis':
    command     => 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -i',
    refreshonly => true,
  }
 
  staging::file { 'C:\staging\CMS4.06.zip':
    source => 'http://master/dotnetcms/CMS4.06.zip',
  }

  exec { 'extract_cms4':
    path        => 'C:\Program Files\7-Zip',
    command     => '7z.exe x C:\staging\CMS4.06.zip -oC:\cms4app',
    refreshonly => true,
    subscribe   => Staging::File['C:\staging\CMS4.06.zip'],
  }

  iis_apppool { 'CMS4':
    ensure                => present,
    startmode             => 'AlwaysRunning',
    managedpipelinemode   => 'Integrated',
    managedruntimeversion => 'v4.0',
    require               => Exec['extract_cms4'],
  }

  iis_site {'CMS4':
    ensure          => present,
    serverautostart => true,
    bindings        => ['http/*:80:'],
    require         => Exec['extract_cms4'],
  }

  iis_app {'CMS4/':
    ensure          => present,
    applicationpool => 'CMS4',
    require         => Exec['extract_cms4'],
  }
  
  iis_vdir {'CMS4/':
    ensure       => present,
    iis_app      => 'CMS4/',
    physicalpath => 'C:\cms4app\CMS',
    require      => Exec['extract_cms4'],
  }

}
